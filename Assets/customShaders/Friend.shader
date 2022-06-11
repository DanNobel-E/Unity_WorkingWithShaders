// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Friend"
{
    Properties
    {
       _Color("Main Color",Color)= (1,1,1,1)
    }
    SubShader
    {
        Tags{"XRay"= "Friend"}
       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

            struct vertexInput
            {
                float4  vertex: POSITION;


            };
            struct vertexOutput{
                float4 pos: SV_POSITION;
            };

            vertexOutput vert(vertexInput v){
            vertexOutput o;

            o.pos= UnityObjectToClipPos(v.vertex);

            return o;
            }
            half4 frag(vertexOutput i): SV_TARGET{
                return _Color;
            }




                        ENDCG
                    }
                }
            }
