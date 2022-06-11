// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureFade"
{
    Properties
    {
       //var ("label", dtype)=default
       _Color("Main Color",Color)= (1,1,1,1)
       _FirstTexture("FirstTexture", 2D)= "white"{}
       _SecondTexture("SecondTexture", 2D)= "white"{}

       _Mipmap("Mipmap", Range(0,5))=0
       _FadignValue("Fading Value",Range(0,1))=0
    }
    SubShader
    {
            Tags{"Queue"="Transparent"}
       

        Pass
        {


            //Blend DstColor Zero, DstColor Zero
            //BlendOp Add, Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            uniform half4 _Color;
            uniform sampler2D _FirstTexture;
            uniform float4 _FirstTexture_ST;  //tiling offset
            uniform sampler2D _SecondTexture;
            uniform float4 _SecondTexture_ST;  //tiling offset
            uniform float _Mipmap;
            uniform float _FadignValue;

struct vertexInput
{
    float4  vertex: POSITION;
float4 texcoord1: TEXCOORD0;
float4 texcoord2: TEXCOORD1;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
    float4 texcoord1: TEXCOORD0;
    float4 texcoord2: TEXCOORD1;

};

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.texcoord1.xy=v.texcoord1.xy*_FirstTexture_ST.xy+_FirstTexture_ST.zw;
o.texcoord2.xy=v.texcoord2.xy*_SecondTexture_ST.xy+_SecondTexture_ST.zw;

return o;
}

half4 frag(vertexOutput i): SV_TARGET{

    half4 texColor1= tex2D(_FirstTexture, i.texcoord1.xy);
    half4 texColor2= tex2D(_SecondTexture, i.texcoord2.xy);

    //half4 texColor= tex2Dlod(_Texture, float4(i.texcoord.xyz,_Mipmap));
    return _Color*(texColor1*_FadignValue+texColor2*(1-_FadignValue));
}




            ENDCG
        }
    }
}
