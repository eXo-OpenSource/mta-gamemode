//
// car_paint.fx
// author: Ren712/AngerMAN
//

//
// Parts of the code from:
//
//      ShaderX2 – Shader Programming Tips and Tricks with DirectX 9
//      http://developer.amd.com/media/gpu_assets/ShaderX2_LayeredCarPaintShader.pdf
//
//      Chris Oat           Natalya Tatarchuk       John Isidoro
//      ATI Research        ATI Research            ATI Research
//

//---------------------------------------------------------------------
// Car paint settings
//---------------------------------------------------------------------
texture sReflectionTexture;
texture sRandomTexture;
texture sFringeMap;

float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0.25);

float sNorFacXY = 0.25;
float sNorFacZ = 1;
float bumpSize = 1;
float envIntensity = 1;

float sAdd = 0.1;  
float sMul = 1.1; 
float sPower = 2;  

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"
float4 gFogColor < string renderState="FOGCOLOR"; >;

//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (gTexture0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
};

sampler2D gFringeMapSampler = sampler_state 
{
   Texture = (sFringeMap);
   MinFilter = Linear;
   MipFilter = Linear;
   MagFilter = Linear;
   AddressU  = Clamp;
   AddressV  = Clamp;
};

sampler3D RandomSampler = sampler_state
{
   Texture = (sRandomTexture);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = POINT;
   MIPMAPLODBIAS = 0.000000;
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
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float4 TexCoord : TEXCOORD0;
    float3 Tangent : TEXCOORD1;
    float3 Binormal : TEXCOORD2;
    float3 Normal : TEXCOORD3;
    float3 NormalSurf : TEXCOORD4;
    float3 View : TEXCOORD5;
    float3 SparkleTex : TEXCOORD6;
    float4 Diffuse2 : COLOR1;
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

    // Transform postion
    float3 worldPosition = MTACalcWorldPosition( VS.Position );
    PS.View = normalize(gCameraPosition - worldPosition);
	
    // Fake tangent and binormal
    float3 Tangent = VS.Normal.yxz;
    Tangent.xz = VS.TexCoord.xy;
    float3 Binormal = normalize( cross(Tangent, VS.Normal) );
    Tangent = normalize( cross(Binormal, VS.Normal) );
	
    // Transfer some stuff
    PS.TexCoord.xy = VS.TexCoord.xy;
    PS.Tangent = normalize(mul(Tangent, gWorldInverseTranspose).xyz);
    PS.Binormal = normalize(mul(Binormal, gWorldInverseTranspose).xyz);
    PS.Normal = normalize( mul(VS.Normal, (float3x3)gWorld) );
    PS.NormalSurf = VS.Normal;

    // Calculate screen pos of vertex	
    float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld );	
    float4 viewPos = mul( worldPos , gView ); 
    float4 projPos = mul( viewPos, gProjection);
    PS.Position = projPos;

    // Reflection lookup coords to pixel shader
    projPos.x *= uvMul.x; projPos.y *= uvMul.y;	
    float projectedX = (0.5 * ( projPos.w + projPos.x ))+ uvMov.x;
    float projectedY = (0.5 * ( projPos.w + projPos.y )) + uvMov.y;
	
    // Set information for the refraction
    float3 ViewNormal = normalize( mul(PS.Normal, (float3x3)gView ));
	
    float2 TexCoord = float2(projectedX,projectedY)/projPos.w; 
    TexCoord.xy += ViewNormal.rg * float2( sNorFacXY, sNorFacZ );
    PS.TexCoord.zw = TexCoord;
	
    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0;

    float NormalZ = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2 ); 
    float3 h = normalize(normalize(gCameraPosition - worldPosition.xyz) - normalize(gCameraDirection));
    PS.Diffuse2.a =  NormalZ * (1 - saturate(pow(saturate(dot(PS.Normal,h)), 2))) * saturate(1 + gCameraDirection.z);
	
    // Calc lighting
    PS.Diffuse2.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, gMaterialSpecPower ) * 0.5;
    PS.Diffuse2.rgb += MTACalcGTADynamicDiffuse( PS.Normal ) * saturate(gMaterialDiffuse/2 + 0.2);
    PS.Diffuse2.rgb = saturate(PS.Diffuse2.rgb);
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );
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
    float4 OutColor = 1;

    float microflakePerturbation = 1.00;
    float normalPerturbation = 1.00;
    float microflakePerturbationA = 0.10;

    float4 base = gMaterialAmbient;

    float4 paintColorMid;
    float4 paintColor2;
    float4 paintColor0;
    float4 flakeLayerColor;

    paintColorMid = base;
    paintColor2.r = base.g / 2 + base.b / 2;
    paintColor2.g = (base.r / 2 + base.b / 2);
    paintColor2.b = base.r / 2 + base.g / 2;

    paintColor0.r = base.r / 2 + base.g / 2;
    paintColor0.g = (base.g / 2 + base.b / 2);
    paintColor0.b = base.b / 2 + base.r / 2;

    flakeLayerColor.r = base.r / 2 + base.b / 2;
    flakeLayerColor.g = (base.g / 2 + base.r / 2);
    flakeLayerColor.b = base.b / 2 + base.g / 2;

    float3 vNormal = PS.Normal;
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;
    vFlakesNormal = 2 * vFlakesNormal - 1.0;
    float3 vNp1 = microflakePerturbationA * vFlakesNormal + normalPerturbation * vNormal ;
    float3 vNp2 = microflakePerturbation * ( vFlakesNormal + vNormal ) ;
    float3 vView = normalize( PS.View );
    float3x3 mTangentToWorld = transpose( float3x3( PS.Tangent, PS.Binormal, PS.Normal ) );
    float3 vNormalWorld = normalize( mul( mTangentToWorld, vNormal ));

    float fNdotV = saturate(dot( vNormalWorld, vView));

    float2 vReflection = PS.TexCoord.zw;
	
    // Hack in some bumpyness
    vReflection.x += vNp2.x *(0.1 * bumpSize) - 0.1 * bumpSize;
    vReflection.y += vNp2.y *(0.05 * bumpSize) - 0.05 * bumpSize;
	
    // Sample environment map using this reflection vector:
    float4 envMap = tex2D( ReflectionSampler, vReflection );

    // basic filter for vehicle effect reflection
    envMap += sAdd;
    envMap = pow(envMap, sPower); 
    envMap *= sMul;
    envMap.rgb = saturate( envMap.rgb );

    // Brighten the environment map sampling result:
    envMap.rgb += gMaterialDiffuse * 0.4;
    envMap.rgb = saturate(envMap.rgb * envIntensity);
    envMap.rgb *= PS.Diffuse2.a;
	
    float4 maptex = tex2D(Sampler0,PS.TexCoord.xy);
    
    float3 vNp1World = normalize( mul( mTangentToWorld, vNp1) );
    float fFresnel1 = saturate( dot( vNp1World, vView ));

    float3 vNp2World = normalize( mul( mTangentToWorld, vNp2 ));
    float fFresnel2 = saturate( dot( vNp2World, vView ));

    float fFresnel1Sq = fFresnel1 * (fFresnel2);

    float4 paintColor = fFresnel1 * paintColor0 +
        fFresnel1Sq * paintColorMid +
        fFresnel1Sq * fFresnel1Sq * paintColor2 +
        pow( fFresnel2, 32 ) * flakeLayerColor;

    float fEnvContribution = 1.0 - 0.5 * fNdotV;
    float4 finalColor = envMap * fEnvContribution + paintColor * 0.8;
    finalColor.rgb += PS.Diffuse2.rgb  * (1 + fFresnel2 * 0.3);
    finalColor.a = 1.0;

    float4 Color = 0.017 + finalColor / 1 + PS.Diffuse * 0.8;
    Color.rgb += finalColor * PS.Diffuse;
    Color *= maptex; 
    Color.a = PS.Diffuse.a;
    return Color;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique carpaint_reflect
{
    pass P0
    {
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
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
