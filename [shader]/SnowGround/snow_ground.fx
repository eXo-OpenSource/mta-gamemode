//
// Example shader - snow_ground.fx
//


//---------------------------------------------------------------------
// settings
//---------------------------------------------------------------------
texture sNoiseTexture;
float sFadeStart = 10;          // Near point where distance fading will start
float sFadeEnd = 80;            // Far point where distance fading will complete (i.e. effect will not be visible past this point)


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#define GENERATE_NORMALS      // Uncomment for normals to be generated
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

//---------------------------------------------------------------------
// Sampler for the noise texture
//---------------------------------------------------------------------
sampler3D SamplerNoise = sampler_state
{
   Texture = (sNoiseTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 NoiseCoord : TEXCOORD1;
  float DistFade : TEXCOORD3;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Make sure normal is valid
    MTAFixUpNormal( VS.Normal );

    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition ( VS.Position );

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate GTA lighting for buildings
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );

    // Distance fade calculation
    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, MTACalcWorldPosition( VS.Position ) );
    PS.DistFade = MTAUnlerp ( sFadeEnd, sFadeStart, DistanceFromCamera );

    // Less snow on upright surfaces
    float3 WorldNormal = MTACalcWorldNormal( VS.Normal );
    PS.DistFade *= WorldNormal.z;

    // Noise texture coords
    float3 WorldPos = MTACalcWorldPosition( VS.Position );
    PS.NoiseCoord.x = WorldPos.x / 48;
    PS.NoiseCoord.y = WorldPos.y / 48;

    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);
    float3 texelNoise = tex3D(SamplerNoise, float3(PS.NoiseCoord.xy,1)).rgb;

    float4 texelSnow = texel.g * 2;

    float distFade = saturate( PS.DistFade.x );

    float amount = texelNoise.y * texelNoise.y * 2;
    amount *= distFade;
    float4 finalColor = lerp( texel, texelSnow, amount );

    finalColor = finalColor * PS.Diffuse;
    finalColor.a = texel.a * PS.Diffuse.a;
    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique snowground
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
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
