// reflective bump test 2_5
// Original By ren712
// Modified ccw

#define GENERATE_NORMALS   
#include "mta-helper.fx"

texture sReflectionTexture;
texture sWetAmountTexture;
int sMaxAnisotropy = 1;

#define xval (0.0)
#define yval (-0.02)
#define xzoom (1)
#define yzoom (0.78)
#define brFac (0.5)
#define efInte (0.6)

#define Linear 2
#define Anisotropic 3

sampler2D baseMap = sampler_state
{
    Texture = (gTexture0);
    // Texture filtering/anisotropy already setup for first sampler
};

sampler2D envMap = sampler_state
{
    Texture = (sReflectionTexture);
    // Texture filtering/anisotropy not required for this env map
    AddressU = Mirror;
    AddressV = Mirror;
    AddressW = Wrap;
};

sampler2D wet_amount = sampler_state
{
    Texture = (sWetAmountTexture);
    // Apply texture filtering/anisotropy
    MinFilter = ( sMaxAnisotropy > 1 ) ? Anisotropic : Linear;
    MipFilter = Linear;
    MaxAnisotropy = sMaxAnisotropy;
    AddressU = Wrap;
    AddressV = Wrap;
};

struct VS_INPUT 
{
    float3 Position : POSITION0;
    float4 Color : COLOR0;
    float2 Texcoord : TEXCOORD0;
    float3 Normal : NORMAL0; 
};

struct VS_OUTPUT 
{
    float4 Position : POSITION0;
    float2 Texcoord : TEXCOORD0;
    float3 TexCoord_proj : TEXCOORD1;
    float4 Diffuse : TEXCOORD3;
    float DistFade : TEXCOORD4;
    float LookDownFade : TEXCOORD5;
    float2 WorldCoords : TEXCOORD7;
};

VS_OUTPUT vertex_shader( VS_INPUT Input )
{
    VS_OUTPUT Output;
    MTAFixUpNormal( Input.Normal );

    float4 worldPosition = mul(float4(Input.Position,1), gWorld);
    Output.Position = mul(worldPosition, gViewProjection);
    Output.Texcoord = Input.Texcoord;
    Output.Diffuse = MTACalcGTABuildingDiffuse( Input.Color );
  
    Output.TexCoord_proj.x = 0.5 * (Output.Position.w + Output.Position.x);
    Output.TexCoord_proj.y = 0.5 * (Output.Position.w - Output.Position.y);
    Output.TexCoord_proj.z = Output.Position.w;

    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, worldPosition.xyz );
    Output.DistFade = MTAUnlerp ( 190, 110, DistanceFromCamera );
    Output.LookDownFade = 1 - dot(Input.Normal,-gCameraDirection);
    Output.WorldCoords = worldPosition.xy / 150;

    return( Output );
}


struct PS_INPUT 
{
    float2 Texcoord : TEXCOORD0;
    float3 TexCoord_proj : TEXCOORD1;
    float4 Diffuse : TEXCOORD3;
    float DistFade : TEXCOORD4;
    float LookDownFade : TEXCOORD4;
    float2 WorldCoords : TEXCOORD7;
};

float4 pixel_shader( PS_INPUT Input ) : COLOR0
{
    // Calc wet amount for this texel
    float4 fvWetAmount = tex2D( wet_amount, Input.WorldCoords );
    float4 fvWetAmount2 = tex2D( wet_amount, Input.WorldCoords/64 );
    fvWetAmount = 1-((1-fvWetAmount) * (1-fvWetAmount2) * 2);
    float amount = 1-fvWetAmount.r;
    amount = saturate(amount);
    amount *= 0.1;
    amount += 0.05;
    amount *= saturate(Input.LookDownFade);

    // Get original texel
    float4 fvBaseColor = tex2D( baseMap, Input.Texcoord ) * Input.Diffuse;

    // Calc lookup coords for env map
    float3 envCoords = float3((Input.TexCoord_proj.xy / Input.TexCoord_proj.z),0) ;
    envCoords.xy += fmod(fvBaseColor.rg*100-25,6)/256;
    envCoords.xy += float2(xval,yval);
    envCoords.xy *= float2(xzoom,yzoom);
    float4 texel = tex2D(envMap,envCoords.xy)*(brFac);

    // Magic
    float lum = (texel.r + texel.g + texel.b)/3;
    float adj = saturate( lum - 0.1 );
    adj = adj / (1.01 - 0.3);
    texel = texel * adj;
    texel += 0.17;

    float4 outPut = fvBaseColor;

    // Something
    outPut.rgb *= 1 - amount;

    // Something
    float darkness = 1 - fvWetAmount.r;
    darkness = darkness + 0.5;
    float brightness = 1-saturate(darkness);
    outPut *= brightness * 0.5 + 0.5;

    // Mix in reflection
    outPut = lerp( outPut, texel, amount );

    // Apply distance fade
    outPut = lerp( fvBaseColor, outPut, saturate(Input.DistFade) );
    outPut.a = fvBaseColor.a;
    return outPut;
}


technique wet_roads
{
   pass P0
   {
        VertexShader = compile vs_2_0 vertex_shader();
        PixelShader = compile ps_2_0 pixel_shader();
   }
}
