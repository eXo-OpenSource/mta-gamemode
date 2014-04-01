//
// skin.fx
//
#include "mta-helper.fx"


int gAreaCount;
float4 gArea1; 
float4 gAreaColor1; 
float4 gArea2; 
float4 gAreaColor2; 
float4 gArea3; 
float4 gAreaColor3; 

sampler TextureSampler = sampler_state
{
    Texture = <gTexture0>;
};

struct PS_INPUT
{
    float4 Position   : POSITION;
    float4 Diffuse 		: COLOR0;
    float2 Texture    : TEXCOORD0;
};
struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 Texture : TEXCOORD0;
};
 
 
//--------------------------------------------------------------------------------------------
//-- VertexShaderFunction
//--  1. Read from VS structure
//--  2. Process
//--  3. Write to PS structure
//--------------------------------------------------------------------------------------------
PS_INPUT VertexShaderFunction(VSInput VS)
{
    PS_INPUT PS = (PS_INPUT)0;
 
    //-- Calculate screen pos of vertex
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
 
    //-- Pass through tex coord
    PS.Texture = VS.Texture;
 
    //-- Calculate GTA lighting for buildings
    //PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );
    //--
    //-- NOTE: The above line is for GTA buildings.
    //-- If you are replacing a vehicle texture, do this instead:
    //--
    //--      // Calculate GTA lighting for vehicles
    //--      float3 WorldNormal = MTACalcWorldNormal( VS.Normal );
    //--      PS.Diffuse = MTACalcGTAVehicleDiffuse( WorldNormal, VS.Diffuse );
	float3 WorldNormal = MTACalcWorldNormal( VS.Normal );
    PS.Diffuse = MTACalcGTAVehicleDiffuse( WorldNormal, VS.Diffuse );
    return PS;
}

float4 PixelShaderFunction(PS_INPUT In) : COLOR0
{
    float4 color = tex2D(TextureSampler, In.Texture);
	if(gAreaCount >= 1)
	{
		if(
			In.Texture[0] > gArea1[0] &&
			In.Texture[0] < gArea1[1] &&
			In.Texture[1] > gArea1[2] &&
			In.Texture[1] < gArea1[3])
		{
			float value = (color.r + color.g + color.b) / 4; 
			color.r = value * gAreaColor1[0];
			color.g = value * gAreaColor1[1];
			color.b = value * gAreaColor1[2];
		}
	}	
	if(gAreaCount >= 2)
	{
		if(
			In.Texture[0] > gArea2[0] &&
			In.Texture[0] < gArea2[1] &&
			In.Texture[1] > gArea2[2] &&
			In.Texture[1] < gArea2[3])
		{
			float value = (color.r + color.g + color.b) / 4; 
			color.r = value * gAreaColor2[0];
			color.g = value * gAreaColor2[1];
			color.b = value * gAreaColor2[2];
		}
	}
	   
	//-- Apply diffuse lighting
    float4 finalColor = color * In.Diffuse;
    return finalColor;
}
 
technique SkinShader
{
    pass P0
    {
		VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
