texture ScreenTexture;

sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float2 center = float2(0.5, 0.5);
float inner_radius = 0.25;
float magnification = 1.3;
float outer_radius = 0.3;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
  float2 uv = TextureCoordinate;
  float2 center_to_pixel = uv - center; // vector from center to pixel
  float distance = length(center_to_pixel);
  float4 color;
  float2 sample_point;

  if(distance < outer_radius) {

    if( distance < inner_radius ) {
       sample_point = center + (center_to_pixel / magnification);
     }
     else {
        float radius_diff = outer_radius - inner_radius;
        float ratio = (distance - inner_radius ) / radius_diff; // 0 == inner radius, 1 == outer_radius
        ratio = ratio * 3.14159; //  -pi/2 .. pi/2
        float adjusted_ratio = cos( ratio );  // -1 .. 1
        adjusted_ratio = adjusted_ratio + 1;   // 0 .. 2
        adjusted_ratio = adjusted_ratio / 2;   // 0 .. 1

        sample_point = ( (center + (center_to_pixel / magnification) ) * (  adjusted_ratio)) + ( uv * ( 1 - adjusted_ratio) );
     }
  }
  else {
     sample_point = uv;
  }

  return tex2D( implicitInputSampler, sample_point );
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
