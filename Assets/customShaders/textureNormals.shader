// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureNormals"
{
    Properties
    {
       //var ("label", dtype)=default
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
          _Speed("Speed",float)=0
       _Amplitude("Amplitude",float)=0
       _Frequency("Frequency",float)=0
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
            uniform half4 _Color;
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST;  //tiling offset
            uniform float _Amplitude;
            uniform float _Frequency;
            uniform float _Speed;

struct vertexInput
{
    float4  vertex: POSITION;
float4 texcoord: TEXCOORD0;

};
struct vertexOutput{
    float4 pos: SV_POSITION;
    float4 texcoord: TEXCOORD0;
};

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.texcoord.xy=v.texcoord.xy*_Texture_ST.xy+_Texture_ST.zw;
return o;
}

half4 frag(vertexOutput i): SV_TARGET{

    half4 texColor= tex2D(_Texture, i.texcoord.xy);
    //half4 texColor= tex2Dlod(_Texture, float4(i.texcoord.xyz,_Mipmap));
    return _Color*texColor;
}




            ENDCG
        }
    }
}
