#include "mta-helper.fx"
float4 color = float4( 1, 1, 0.2, 1 );

float4 gMaterialAmbientColor =  {1.0, 1.0, 1.0, 1.0};     // Material's ambient color
float4 gMaterialDiffuseColor =  {1.0, 1.0, 1.0, 1.0};      // Material's diffuse color


technique tec0
{
    pass P0
    {
        MaterialAmbient = color;
        MaterialDiffuse = color;
        MaterialEmissive = color;
        MaterialSpecular = color;

        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;

        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;

        Lighting = true;
    }
}


