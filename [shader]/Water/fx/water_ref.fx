// Author: Ren712/AngerMAN
// Water_refract 2.6

texture sReflectionTexture;
texture sRandomTexture;
float4 sWaterColor = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );
float3 sSkyColorTop = float3(0,0,0);
float3 sSkyColorBott = float3(0,0,0);

float gBuffAlpha = 0.26;
float normalMult =0.5;

float xval = 0.0;
float yval = 0.0;
float xzoom = 1;
float yzoom = 1;

float gDepthFactor =0.03f;
#include "mta-helper.fx"
texture gDepthBuffer : DEPTHBUFFER;
matrix gProjectionMainScene : PROJECTION_MAIN_SCENE;

//---------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//---------------------------------------------------------------------

sampler2D colorMapSampler = sampler_state
{
    Texture = (gTexture0);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

sampler2D RandomSampler = sampler_state
{
   Texture = (sRandomTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

sampler SamplerDepth = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
};

samplerCUBE ReflectionSampler = sampler_state
{
   Texture = (sReflectionTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//--------------------------------------------------------------------- 
 
 struct VSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;
	float4 Diff : COLOR0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------

struct PSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0; 
	float4 Diff : COLOR0;
	float4 Diffuse : COLOR1;
	float4 SparkleTex : TEXCOORD1;
	float3 WorldPos : TEXCOORD2;
	float DistFade : TEXCOORD3;
};

//-----------------------------------------------------------------------------
//-- VertexShader
//-----------------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
    PSInput PS = (PSInput)0;
 
    // Position in screen space.
	PS.Position = mul(float4(VS.Position.xyz , 1.0), gWorldViewProjection);

	float4 pPos = mul(VS.Position, gWorldViewProjection); 
    // compute the eye vector 
	PS.TexCoord.x = (0.5 * (pPos.w + pPos.x));
	PS.TexCoord.y = (0.5 * (pPos.w - pPos.y));
	PS.TexCoord.z = pPos.w;

	// Convert regular water color to what we want
    float4 waterColorBase = float4(90 / 255.0, 170 / 255.0, 170 / 255.0, 240 / 255.0 );
    float4 conv           = float4(30 / 255.0,  58 / 255.0,  58 / 255.0, 200 / 255.0 );
    PS.Diff = saturate( sWaterColor * conv / waterColorBase );
	
	// Set information to do calculations in pixel shader
    PS.WorldPos = MTACalcWorldPosition( VS.Position.xyz );

    // Scroll noise texture
    float2 uvpos1 = 0;
    float2 uvpos2 = 0;

    uvpos1.x = sin(gTime/40);
    uvpos1.y = fmod(gTime/50,1);

    uvpos2.x = fmod(gTime/10,1);
    uvpos2.y = sin(gTime/12);

    PS.SparkleTex.x = VS.TexCoord.x * 1 + uvpos1.x;
    PS.SparkleTex.y = VS.TexCoord.y * 1 + uvpos1.y;
    PS.SparkleTex.z = VS.TexCoord.x * 2 + uvpos2.x;
    PS.SparkleTex.w = VS.TexCoord.y * 2 + uvpos2.y;
	
	// Calculate GTA lighting for buildings
    PS.Diffuse =MTACalcGTABuildingDiffuse( VS.Diff );

 	float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition,MTACalcWorldPosition( VS.Position.xyz ) );
    PS.DistFade = MTAUnlerp ( 580, 0, DistanceFromCamera );
 
    return PS;
}

//-----------------------------------------------------------------------------
//-- Get value from the depth buffer
//-- Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
//-----------------------------------------------------------------------------
float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
    return dot(rawval, valueScaler / 255.0);
#else
    return texel.r;
#endif
}

 //-----------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//-----------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}
//-----------------------------------------------------------------------------
//-- PixelShader
//-----------------------------------------------------------------------------
float4 PixelShaderSB(PSInput PS) : COLOR0
{
    float brightnessFactor = 0.33;

    float3 vFlakesNormal = tex2D(RandomSampler, PS.SparkleTex.xy).rgb;
    float3 vFlakesNormal2 = tex2D(RandomSampler, PS.SparkleTex.zw).rgb;

    vFlakesNormal = (vFlakesNormal + vFlakesNormal2 ) /2 ;
    vFlakesNormal = 2 * vFlakesNormal-1.0;
    float3 fvNormal = normalize(float3(vFlakesNormal.x * normalMult, vFlakesNormal.y * normalMult, vFlakesNormal.z)); 	

	float3 projcoord = float3((PS.TexCoord.xy / PS.TexCoord.z),0) ;
    float3 norNor = (fvNormal.x * float3(1,0,0) + fvNormal.y * float3(0,1,0));	
    projcoord.xy += norNor.xy;	
    projcoord.xy += float2(xval,yval);
    projcoord.xy *= float2(xzoom,yzoom);
	
	float BufferValue= Linearize(FetchDepthBufferValue(projcoord.xy))*gDepthFactor;
	float3 refracColor = saturate(float3(sSkyColorTop.r,sSkyColorTop.g,sSkyColorTop.b)*2)* BufferValue;
	float4 reflection=float4(refracColor,1)*gBuffAlpha;
	reflection.rgb*=reflection.a;
	reflection.rgb*= brightnessFactor;
    reflection *=saturate(PS.DistFade);
	reflection *=pow(PS.Diffuse,0.3)/4;

    // Calc Sky color reflection
    float3 cameraDirection = float3(gCameraDirection.xy,saturate(gCameraDirection.z));
    float3 h = normalize(normalize(gCameraPosition - PS.WorldPos.xyz) - normalize(cameraDirection));
    float vdn = saturate(pow(saturate(dot(h,vFlakesNormal)), 1));
    float3 skyColorTop = lerp(0,sSkyColorTop,vdn);	
    float3 skyColorBott = lerp(0,sSkyColorBott,vdn);
    float3 skyColor = lerp(skyColorBott,skyColorTop,saturate(PS.DistFade));	
	
	float4 finalColor = 1;
    finalColor = saturate(reflection + PS.Diff * 0.5);
    finalColor.rgb += skyColor *0.18;
    finalColor += reflection * PS.Diff;
    finalColor.a = PS.Diff.a;
    return finalColor;
	
}

float4 PixelShaderNonB(PSInput PS) : COLOR0
{


    float brightnessFactor = 0.10;
    float glossLevel = 0.00;

    // Get the surface normal
    float3 vNormal = float3(0,0,1);

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    // Fetching the value from it for each pixel allows us to
    // compute perturbed normal for the surface to simulate
    // appearance of micro-flakes suspended in the coat of paint:
    float3 vFlakesNormal = tex2D(RandomSampler, PS.SparkleTex.xy).rgb;
    float3 vFlakesNormal2 = tex2D(RandomSampler, PS.SparkleTex.zw).rgb;

    vFlakesNormal = (vFlakesNormal + vFlakesNormal2 ) / 2;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp2 = ( vFlakesNormal + vNormal ) ;

    // The view vector (which is currently in world space) needs to be normalized.
    // This vector is normalized in the pixel shader to ensure higher precision of
    // the resulting view vector. For this highly detailed visual effect normalizing
    // the view vector in the vertex shader and simply interpolating it is insufficient
    // and produces artifacts.
    float3 vView = normalize( gCameraPosition - PS.WorldPos.xyz );

    // Transform the surface normal into world space (in order to compute reflection
    // vector to perform environment map look-up):
    float3 vNormalWorld = vNormal;

    // Compute reflection vector resulted from the clear coat of paint on the metallic
    // surface:
    float fNdotV = saturate(dot( vNormalWorld, vView));
    float3 vReflection = 2 * vNormalWorld * fNdotV - vView;

    // Hack in some bumpyness
    vReflection += vNp2;

    // Calc Sky color reflection
    float3 cameraDirection = float3(gCameraDirection.xy,saturate(gCameraDirection.z));
    float3 h = normalize(normalize(gCameraPosition - PS.WorldPos.xyz) - normalize(cameraDirection));
    float vdn = saturate(pow(saturate(dot(h,vNp2)), 1));
    float3 skyColorTop = lerp(0,sSkyColorTop,vdn);	
    float3 skyColorBott = lerp(0,sSkyColorBott,vdn);
    float3 skyColor = lerp(skyColorBott,skyColorTop,saturate(PS.DistFade));	
	
    // Sample environment map using this reflection vector:
    float4 envMap = texCUBE( ReflectionSampler, vReflection );
    float envGray = (envMap.r + envMap.g + envMap.b)/3;
    envMap.rgb = float3(envGray,envGray,envGray);
    envMap.rgb = envMap.rgb * envMap.a;	
	
    // Brighten the environment map sampling result:
    envMap.rgb *= envMap.rgb;
    envMap.rgb *= brightnessFactor;
    envMap.rgb = saturate(envMap.rgb);
    float4 finalColor = 1;

    // Bodge in the water color
    finalColor = envMap + PS.Diff * 0.5;
    finalColor += envMap * PS.Diff;
    finalColor.rgb += skyColor *0.18;
    finalColor.a = PS.Diffuse.a;
    return finalColor;
}

////////////////////////////////////////////////////////////
//////////////////////////////// TECHNIQUES ////////////////
////////////////////////////////////////////////////////////
technique Water_refract_2_1
{
    pass P0
    {
        AlphaBlendEnable = TRUE;
        AlphaRef = 1;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();
    }
}

technique Water_simple
{
    pass P0
    {
        AlphaBlendEnable = TRUE;
        AlphaRef = 1;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderNonB();
    }
}
// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
