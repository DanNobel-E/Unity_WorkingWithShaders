// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/_elements"
{
	Properties
	{
		[KeywordEnum(stroke, circle, fill, rect, flip, tri, rotate, sinusoide, oblique,cross, fillQuad, lineRect, flipQuad)] _Element ("Element", Float) = 0
		_Start("Start", Float)=0.5
		_Width("Width", Float)=0.25
		_Offset("Offset", Vector)= (0,0,0)

		_Variance0("Variance0", Float)=1
		_Variance1("Variance1", Float)=1
		_Variance2("Variance2", Float)=1


	}
	Subshader
	{
		Tags{"Queue" = "Geometry" "RenderType" = "Opaque"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform float _Element;
			uniform float _Start;
			uniform float _Width;
			uniform float4 _Offset;

			uniform float _Variance0;
			uniform float _Variance1;
			uniform float _Variance2;




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

			float stroke(float x, float s, float w)
			{
				float d = step(s,x+w*0.5) - step(s,x-w*0.5);
				return clamp(d,0,1);
			}

			float strokeSin(float x, float y, float s, float w)
			{
				
				float d = step(s,x+w*0.5+sin(y*_Variance0+_Variance2)*_Variance1) - step(s,x-w*0.5+sin(y*_Variance0+_Variance2)*_Variance1);
				return clamp(d,0,1);
			}

			float strokeXY(float x, float y, float s, float w, float offset,bool flip=false)
			{
				int f=1;

				if(flip)
				{
					f=-1;
				}

				float d = step(s+(0.5*sign(offset)*f),x+w*0.5+(y*sign(offset)*f)) - step(s+(0.5*sign(offset)*f),x-w*0.5+(y*sign(offset)*f));

				
				return clamp(d,0,1);

			}
			float circle(float2 st)
			{
				//length(st-0.5) is -1 at the center, 1 at the border: we'll stroke a circle at half the quad
				//length(st-float2(0.5,0.5))
				return length(st-0.5)*2.0;
			}

			float fill(float x, float size)
			{
				return 1 - step(size, x);
			}

			float rect(float2 st, float2 s)
			{
				st = st*2-1;
				return max(abs(st.x/s.x), abs(st.y/s.y));
			}

			float flip(float v, float pct)
			{
				return lerp(v, 1.0-v, pct);
			}

			float tri(float2 st, float2 offset)
			{
				float x = (st.x*2-1)*2+offset.x;
				float y=(st.y*2-1)*2+offset.y;
				st= float2(x,y);
				return max(	abs(st.x) * 0.866025 +
							st.y * 0.5, -st.y * 0.5);
			}

			float2 rot(float2 st, float a)
			{
				float2x2 rotM = float2x2(cos(a),-sin(a), sin(a), cos(a));
				st -= float2(0.5, 0.5);
				st = mul(rotM, st);
				st += float2(0.5, 0.5);
				return st;
			}

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(vertexOutput i): COLOR
			{
				float result = 0;
				float2 st = i.texcoord.xy;

				if(_Element == 0){
					result = stroke(st.x, _Start, _Width);
				}
				else if (_Element == 1){
					result = stroke(circle(st), _Start, _Width);
				}
				else if (_Element == 2){
					result += fill(circle(st), _Start);
					//If we subtract offset, we are translating the circle center towards top-right corner 
					result -= fill(circle(st-_Offset.xy), _Width);
				}
				else if (_Element == 3){
					float sdf = rect(st, _Offset.xy);
					result += stroke(sdf, _Start, _Width);
				}
				else if (_Element == 4){
					float2 offset = _Offset.xy;
					float r = rect(st+offset, _Offset.zw);
					float r2 = rect(st-offset, _Offset.zw);
					result += flip(fill(r, _Variance0), fill(r2, _Variance1));
				}
				else if (_Element == 5){
					result += fill(tri(st,_Offset.xy), _Width);
				}
				else if (_Element == 6){
					float2 offset = _Offset.xy;
					result += fill(tri(st,_Offset.zw),_Width);
					st+=offset;
					st = rot(st, radians(_Variance0));
					result += fill(tri(st,_Offset.zw),_Width);
				}else if (_Element == 7){

					float s1 = strokeSin(st.x,st.y, _Start, _Width);
					float s2 = strokeSin(st.x,st.y, _Start+_Offset.x, _Width);
					float s3= strokeSin(st.x,st.y, _Start-_Offset.x, _Width);
					result= clamp(s1+s2+s3,0,1);


				}else if (_Element == 8){

				result=strokeXY(st.x,st.y,_Start,_Width,_Offset.x) ;

				}else if (_Element == 9){

				float s1 =strokeXY(st.x,st.y,_Start,_Width, _Offset.x) ;
				float s2 =strokeXY(st.x,st.y,_Start,_Width, _Offset.x, true) ;
					
					
				result= clamp(s1+s2,0,1);


				}else if (_Element == 10){

					float sdf1 = rect(st, _Offset.xy);
					float r1 = stroke(sdf1, _Start, _Width);
					float sdf2 = rect(st, _Offset.zw);
					float r2 = stroke(sdf2, _Variance0, _Variance1);

	

					result= clamp(r1+r2,0,1);
				

				}else if (_Element == 11){

					float sdf = rect(st, _Offset.xy);
					float r = stroke(sdf, _Start, _Width);
					float s=strokeXY(st.x,st.y,_Variance0,_Variance1,_Offset.z) ;

					if(r+s==2){
						r=0,
						s=0;
					}

					result= clamp(r+s,0,1);

				}else if (_Element == 12){

					float2 offset = _Offset.xy;
					st = rot(st, radians(_Variance2));
					float r = rect(st+offset, _Offset.zw);
					float r2 = rect(st-offset, _Offset.zw);
					result += flip(fill(r, _Variance0), fill(r2, _Variance1));


				}
				half4 finalColor = float4(result.xxx,1);

				return finalColor;
			}

			ENDCG
		}
	}
}
