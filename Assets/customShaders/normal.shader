// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/normal"
{
    Properties
    {
       //var ("label", dtype)=default
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
       _NormalMap("Normal Map", 2D)= "white"{}
    }
    SubShader
    {

        Pass
        {

            Tags{"Queue"="Transparent" "RenderTypre"="Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0


            #include "UnityCG.cginc"

            uniform half4 _Color;
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST;  //tiling offset
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;
struct vertexInput
{
    float4  vertex: POSITION;
    float4 texcoord: TEXCOORD0;
    float4  normal: NORMAL;
    float4  tangent: TANGENT;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
    float4 normalW: TEXCOORD1;
    float4 tangentW: TEXCOORD2;
    float3 binormalW: TEXCOORD3; //cross defined only for 3 or 7 dimensions

    float4 texcoord: TEXCOORD0;
    float4 normalTexcoord: TEXCOORD4;


};

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.texcoord.xy=v.texcoord.xy*_Texture_ST.xy+_Texture_ST.zw;

o.normalW= float4(UnityObjectToWorldNormal(v.normal.xyz),v.normal.w);
o.tangentW= float4(UnityObjectToWorldDir(v.tangent.xyz),v.tangent.w);
o.binormalW= float3(normalize(cross(o.normalW.xyz,o.tangentW.xyz)*v.tangent.w)); //UV Flip correct
o.binormalW*=unity_WorldTransformParams.w;

o.normalTexcoord.xy= v.texcoord.xy*_NormalMap_ST.xy+_NormalMap_ST.zw;

return o;
}

float3 normalFromColor(float4 color){



#if defined(UNITY_NO_DXT5nm)

    //RGB is xyz
    return color.xyz*2-1;

#else

float3 normalDecompressed;
normalDecompressed= float3(color.a*2-1,
                            color.g*2-1,
                            0);

normalDecompressed.z= sqrt(1-dot(normalDecompressed.xy, normalDecompressed.xy));
return normalDecompressed;
#endif


}


half4 frag(vertexOutput i): SV_TARGET{

    half4 texColor= tex2D(_Texture, i.texcoord.xy);
    half4 normalColor= tex2D(_NormalMap, i.normalTexcoord.xy);
    float3 TSNormal= normalFromColor(normalColor);
    float3x3 TBNWorld=float3x3(i.tangentW.x, i.binormalW.x, i.normalW.x,
                                i.tangentW.y, i.binormalW.y, i.normalW.y,
                                i.tangentW.z, i.binormalW.z, i.normalW.z);

    float3 normalWAtPixel=normalize(mul(TBNWorld,TSNormal));
   
   //WN debug
   //return i.normalW;
   //return normalColor;

   return half4(normalWAtPixel.xyz,1);



    return _Color*texColor;
}




            ENDCG
        }
    }
}
