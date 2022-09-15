#ifndef CUSTOMFOGINCLUDED
#define CUSTOMFOGINCLUDED

uniform half3 u_SunDirection;
uniform half3 u_SunColor;
uniform half u_FogSunStrength =1;
uniform half3 u_ColorHigh;
uniform half3 u_ColorMid;
uniform half3 u_ColorLow;
uniform half u_FogSunNear;
uniform half u_FogSunFar;
uniform half u_LevelHigh;
uniform half u_LevelLow;
uniform half u_FogSunSize;
uniform half u_FogSunSharpness;
uniform half u_SunFogExponent;

real ComputeCustomFogIntensity(real fogFactor)
{
    real fogIntensity = 0.0h;
    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
        #if defined(FOG_EXP)
            // factor = exp(-density*z)
            // fogFactor = density*z compute at vertex
            fogIntensity = saturate(exp2(-fogFactor));
        #elif defined(FOG_EXP2)
            // factor = exp(-(density*z)^2)
            // fogFactor = density*z compute at vertex
            fogIntensity = saturate(exp2(-fogFactor * fogFactor));
        #elif defined(FOG_LINEAR)
            fogIntensity = fogFactor;
        #endif
    #endif
    return fogIntensity;
}

half3 MixCustomFogColor(real3 fragColor, real3 fogColor, real fogFactor)
{
    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
        real fogIntensity = ComputeCustomFogIntensity(fogFactor);
        fragColor = lerp(fogColor, fragColor, fogIntensity);
    #endif
    return fragColor;
}


void GetSunDir_half(out half3 SunDir)
{
    SunDir = u_SunDirection;
    #ifdef SHADERGRAPH_PREVIEW
        SunDir = half3(-0.5f,0.5f,0);
    #endif
}

void GetSunColor_half(out half3 SunColor)
{
    SunColor = u_SunColor;
}

void GetColorHigh_half(out half3 ColorHigh)
{
    ColorHigh = u_ColorHigh;
}

void GetColorMid_half(out half3 ColorMid)
{
    ColorMid = u_ColorMid;
}

void GetColorLow_half(out half3 ColorLow)
{
    ColorLow = u_ColorLow;
}

void GetLevelHigh_half(out half LevelHigh)
{
    LevelHigh = u_LevelHigh;
}

void GetLevelLow_half(out half LevelLow)
{
    LevelLow = u_LevelLow;
}

void GetFogSunSize_half(out half FogSunSize)
{
    FogSunSize = u_FogSunSize;
}

void GetSunFogExponent_half(out half SunFogExponent)
{
    SunFogExponent = u_SunFogExponent;
}

void GetFogSunFar_half(out half FogSunFar)
{
    FogSunFar = u_FogSunFar;
}

void GetFogSunNear_half(out half FogSunNear)
{
    FogSunNear = u_FogSunNear;
}

void GetFogSunStrength_half(out half FogSunStrength)
{
    FogSunStrength = u_FogSunStrength;
}


half3 CustomFog(real3 fragColor, real fogFactor, half3 posWS)
{
    half3 cameraVector = normalize(posWS -_WorldSpaceCameraPos) ;// posWS;// Dot(u_SundDirection
    half sunFade =  dot(u_SunDirection, cameraVector);
    sunFade = saturate((sunFade+1) * 0.5f);
    sunFade = saturate((sunFade - (1-u_FogSunSize)) * (1 / u_FogSunSize));
    sunFade = pow(sunFade,u_SunFogExponent);
    sunFade *= saturate( (fogFactor - u_FogSunNear) / (u_FogSunFar-u_FogSunNear) );
    half heightFactor = saturate( ( ( (cameraVector.y + 1) * 0.5f ) - u_LevelLow ) / ( u_LevelHigh - u_LevelLow) );  
    half3 heightColor = lerp(u_ColorLow,u_ColorMid, saturate(heightFactor*2));
    heightColor = lerp(heightColor, u_ColorHigh, saturate((heightFactor-0.5f)*2));
    half3 fogColor = heightColor;
    fogColor += u_SunColor * sunFade * u_FogSunStrength;

    return MixCustomFogColor(fragColor, fogColor.rgb, fogFactor);
}


#endif //CUSTOMFOGINCLUDED
