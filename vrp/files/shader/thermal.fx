float4 color = float4( 1, 1, 1, 1 );

technique tec0
{
    pass P0
    {
        MaterialAmbient = color;
        MaterialDiffuse = color;
        MaterialEmissive = color;
        MaterialSpecular = color;

        AmbientMaterialSource = Material;
        DiffuseMaterialSource = Material;
        EmissiveMaterialSource = Material;
        SpecularMaterialSource = Material;

        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;

        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;


        Lighting = false;
    }
}


