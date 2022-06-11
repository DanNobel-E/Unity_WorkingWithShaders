#ifndef CGLIGHTING
#define CGLIGHTING
    float3 normalFromColor(float4 color)
    {
        #if defined(UNITY_NO_DXT5nm)
            return color.xyz * 2 - 1;
        #else
            float3 normalDecompressed;
            normalDecompressed = float3(color.a * 2 - 1,
                                        color.g * 2 - 1,
                                        0);
            normalDecompressed.z = sqrt(1 - dot(normalDecompressed.xy, normalDecompressed.xy));
            return normalDecompressed;
        #endif
    }
#endif