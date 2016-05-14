//
// Example shader - ped_shell_layer.fx
//


//---------------------------------------------------------------------
// Ped shell settings
//---------------------------------------------------------------------
float3 sMorphSize = float3(0,0,0);
float4 sMorphColor = float4(1,1,1,1);


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


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

    // Do morph effect by adding surface normal to the vertex position
    VS.Position += VS.Normal * sMorphSize;

    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition ( VS.Position );

    // Pass through tex coords
    PS.TexCoord = VS.TexCoord;

    // Set our custom morph color
    PS.Diffuse.rgb = sMorphColor.rgb * sMorphColor.a;
    PS.Diffuse.a = 1;

    return PS;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        // As this shader is used as a separate layer, we just have to draw our effect
        // and not worry about the main rendering

        // SrcBlend and DestBlend can be set for various effects
        // This combination gives a translucent look
        SrcBlend = SrcColor;
        DestBlend = One;

        VertexShader = compile vs_2_0 VertexShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // As this shader is used as a separate layer, don't draw anything
        SrcBlend = Zero;
        DestBlend = One;
    }
}
