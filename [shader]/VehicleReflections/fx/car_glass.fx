//
// car_glass.fx
// author: Ren712/AngerMAN
//

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0.25);
float sNorFacXY = 0.25;
float sNorFacZ = 1;
float bumpSize = 1;
float envIntensity = 1;
float specularValue = 1;
float refTexValue = 0.2;

float sAdd = 0.1;  
float sMul = 1.1; 
float sPower = 2; 

bool isShatter = false;
texture sReflectionTexture;

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

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
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
  float2 TexCoord1 : TEXCOORD1;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float4 Specular : COLOR1;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : TEXCOORD1;
  float3 WorldPos : TEXCOORD2;
  float3 PosProj : TEXCOORD3;
  float3 ViewNormal : TEXCOORD6;
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
	
    // Set information to do specular calculation in pixel shader
    PS.Normal = MTACalcWorldNormal( VS.Normal );
    PS.WorldPos = MTACalcWorldPosition( VS.Position );
	
    // Pass through tex coords
    PS.TexCoord = VS.TexCoord;
	
    // Calculate screen pos of vertex	
    float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld );	
    float4 viewPos = mul( worldPos , gView ); 
    float4 projPos = mul( viewPos, gProjection);
    PS.Position = projPos;

    // Reflection lookup coords to pixel shader
    projPos.x *= uvMul.x; projPos.y *= uvMul.y;	
    float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x;
    float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y;
    PS.PosProj = float3(projectedX,projectedY,projPos.w );
	
    // Set information for the refraction
    PS.ViewNormal = normalize( mul(PS.Normal, (float3x3)gView) );
	
    // Calculate GTA vehicle lighting
    PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse );
    PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, gMaterialSpecPower ) * specularValue;
 
    // Calc Specular 
    PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2 ); 
    float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection));
    PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2));
    PS.Specular.a *= saturate(1 + gCameraDirection.z);
	
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
    float microflakePerturbation = 1.00;
	
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);
	
    float2 TexCoord = PS.PosProj.xy/PS.PosProj.z;
    TexCoord += PS.ViewNormal.rg * float2(sNorFacXY,sNorFacZ);
    float4 envMap = tex2D( ReflectionSampler, TexCoord );
	
    // basic filter for vehicle effect reflection
    envMap += sAdd; 
    envMap = pow(envMap, sPower); 
    envMap *= sMul;
    envMap = saturate( envMap * envIntensity );
	
    // Apply diffuse lighting
    float4 finalColor = texel * PS.Diffuse;

    // Apply specular
    finalColor.rgb += PS.Specular.rgb;
	
    if ((isShatter) ||(PS.Diffuse.a <= 0.85)) finalColor.rgb += envMap.rgb * PS.Specular.a;
    if (isShatter)  finalColor.a = max(0, texel.a);
    finalColor.rgb += saturate(0.5 * gMaterialSpecular.rgb * refTexValue);

    return saturate(finalColor);
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_paint_reflect_glass
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
