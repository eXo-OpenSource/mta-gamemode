float4 color = float4( 0, 0, 0, 1 );

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

        Lighting = false;
    }
}


