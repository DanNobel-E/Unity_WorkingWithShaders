// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/positionalColor_obj"
{
    Properties
    {
       //var ("label", dtype)=default
       _LeftColor("Left Color",Color)= (1,1,1,1)
       _RightColor("Right Color",Color)= (0,0,0,1)

       _MinX("MinX",float)= 0
       _MaxX("MaxX",float)= 1
        

    }
    SubShader
    {
       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _LeftColor;
            uniform half4 _RightColor;
            uniform float _MinX;
            uniform float _MaxX;

struct vertexInput
{
    float4  vertex: POSITION; //vertex position


};
struct vertexOutput{
    float4 pos: SV_POSITION; //Screen view
    float xRange: DEPTH0;
};

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.xRange= smoothstep(_MinX,_MaxX,v.vertex.x);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{


        half4 l= _LeftColor;
        half4 r= _RightColor;
        half4 c= i.xRange*l+(1-i.xRange)*r;
        return c;

    
}




            ENDCG
        }
    }
}
