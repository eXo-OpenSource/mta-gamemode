// fixed dependency
texture ScreenTexture;

// Params {
float curviness = 0.05;
//}

// Static Vars { 
static float PI = 3.14159265358979323846;
//}

sampler defaultSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float4 cylinder(float2 uv : TEXCOORD) : COLOR 
{ 
    float y = uv.y+(sin(uv.x*PI) * lerp(-1,1,uv.y) * curviness);
    
    if(y < 0 || y > 1) {
        return float4(0,0,0,1);
    }
    else {
        float4 ret = tex2D(defaultSampler,float2(uv.x,y));
        ret.a = 1;
        return ret;
    }
}

technique Technique1
{

   pass Pass4
    {
        PixelShader = compile ps_2_0 cylinder();
    }   
}