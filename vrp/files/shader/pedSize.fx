float3 size = float3(0,0,0);
//float3 lel = float3(2, 0, 0);

#include "mta-helper.fx"

struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    VS.Position += VS.Position * size;

    PS.Position = MTACalcScreenPosition ( VS.Position );

    PS.TexCoord = VS.TexCoord;

    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );

    return PS;
}

technique tec0
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
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