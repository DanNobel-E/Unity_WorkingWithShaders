// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/grabScreen"
{
    Properties
    {
        _Color ("MainColor", Color) = (1,1,1,1)
        _MainTexture ("MainTexture", 2D) = "white" {}
    }
    SubShader
    {


        Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}

        //GrabPass{"_BackgroundTexture"}
        GrabPass{}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;
            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST; //tiling offset

            //uniform sampler2D _BackgroundTexture;
            uniform sampler2D _GrabTexture;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;

                return o;
            }

            half4 frag(vertexOutput i): SV_Target
            {
                //half4 texColor = tex2D(_BackgroundTexture, i.texcoord.xy);
                half4 texColor = tex2D(_GrabTexture, i.texcoord.xy);
                return _Color * texColor;
            }

            ENDCG
        }
    }
}
