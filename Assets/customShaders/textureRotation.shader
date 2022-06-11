// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureRotation"
{
    Properties
    {
       //var ("label", dtype)=default
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
       _Mipmap("Mipmap", Range(0,5))=0
       _AlphaDeg("AlphaDeg",Range(0,360))=0
       _CenterX("CenterX", Range(0,1))=0
       _CenterY("CenterY", Range(0,1))=0

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
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST;  //tiling offset
            uniform float _Mipmap;
            uniform float _AlphaDeg;
            uniform float _CenterX;
            uniform float _CenterY;

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


float alphaRad= radians(_AlphaDeg);
float cosA= cos(alphaRad);
float sinA= sin(alphaRad);
float2x2 rotM=float2x2(cosA,-sinA,sinA,cosA);

v.texcoord.xy-= float2(_CenterX,_CenterY);
v.texcoord.xy=mul(rotM,v.texcoord.xy);
v.texcoord.xy+= float2(_CenterX,_CenterY);


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
