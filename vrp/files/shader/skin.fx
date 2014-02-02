//
// skin.fx
//
texture gTexture0           < string textureState="0,Texture"; >;
int gAreaCount;
float4 gArea1; 
float4 gAreaColor1; 
float4 gArea2; 
float4 gAreaColor2; 
float4 gArea3; 
float4 gAreaColor3; 

//
// Strongest light influence
//
float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialSpecular    < string materialState="Specular"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;
float gMaterialSpecPower    < string materialState="Power"; >;

float4 gGlobalAmbient              < string renderState="AMBIENT"; >;                    //  = 139,

sampler TextureSampler = sampler_state
{
    Texture = <gTexture0>;
};

struct PS_INPUT
{
    float4 Position   : POSITION;
    float2 Texture    : TEXCOORD0;
};

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
    return (color * gGlobalAmbient* gMaterialAmbient + color* gMaterialDiffuse/3) / 2;
}
 
technique BlackAndWhite
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
