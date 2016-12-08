//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"

float distance = 9;

 
sampler DepthBufferSampler = sampler_state
{
    Texture     = (gDepthBuffer);
    AddressU    = Clamp;
    AddressV    = Clamp;
};

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(DepthBufferSampler, uv);
	
	#if IS_DEPTHBUFFER_RAWZ
		float3 rawval = floor(255.0 * texel.arg + 0.5);
		float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
		return dot(rawval, valueScaler / 255.0);
	#else
		return texel.r;
	#endif
}
 

float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}


 
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------


float4 DoFPixelShader(float2 texCoords : TEXCOORD) : COLOR
{
    float BufferValue = FetchDepthBufferValue(texCoords.xy );
    float Depth = Linearize(BufferValue);
 
    //-- Multiply Depth to get the spread you want
    Depth *= distance / 1000;
	float4 depthColor = float4(Depth, Depth, Depth, 1);
	//depthColor = float4(depthColor.a - depthColor.rgb, depthColor.a);
	
	if (depthColor.r > 1) {depthColor.r = 1;}
	if (depthColor.g > 1) {depthColor.g = 1;}
	if (depthColor.b > 1) {depthColor.b = 1;}
	if (depthColor.a > 1) {depthColor.a = 1;}
	
    return depthColor;
}

 
//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------
technique DoF
{
    pass p0
    {
		AlphaBlendEnable = True;
		PixelShader = compile ps_2_0 DoFPixelShader();
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
