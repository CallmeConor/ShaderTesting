Shader "Unlit/TransitionUnlit"
{
	Properties
	{
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_DirtTex("Dirt Texture (RGB)", 2D) = "white" {}
		_CleanProgress("Clean Progress", Range(0,1)) = 0.5
		_CleanProgress1("Clean Progress", Range(0,1)) = 0.5
		_CleanProgress2("Clean Progress", Range(0,1)) = 0.5
		_CleanProgress3("Clean Progress", Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Fade" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _DirtTex;
			float4 _MainTex_ST;
			half _CleanProgress;
			half _CleanProgress1;
			half _CleanProgress2;
			half _CleanProgress3;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 main = tex2D(_MainTex, i.uv);
				fixed4 sec = tex2D(_DirtTex, i.uv);

				fixed4 col = lerp(main, sec, _CleanProgress * 0.25);

				if (i.uv.y > 1- _CleanProgress && i.uv.x < 0.25)
				{
					col = sec;
				}
				else if (i.uv.y > 1 - _CleanProgress1 && i.uv.x >= 0.25 && i.uv.x < 0.5)
				{
					col = sec;
				}
				else if (i.uv.y > 1 - _CleanProgress2 && i.uv.x >= 0.5 && i.uv.x < 0.75)
				{
					col = sec;
				}
				else if (i.uv.y > 1 - _CleanProgress3 && i.uv.x >= 0.75 && i.uv.x <= 1)
				{
					col = sec;
				}

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
