Shader "Custom/PaintingShader"
{
	Properties
	{
		_MainTex("Dirt Texture", 2D) = "white" {}
		_CleanTex("Clean Texture", 2D) = "white" {}
		[HideInInspector] PaintUv("PaintUv", VECTOR) = (0,0,0,0)
		PaintBrushSize("BrushSize", VECTOR) = (0,0,0,0)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				sampler2D _CleanTex;
				float4 _MainTex_ST;
				float2 PaintBrushSize;
				float2 PaintUv;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}


				fixed4 frag(v2f i) : SV_Target
				{
					if (distance(i.uv.x, PaintUv.x) < PaintBrushSize.x
					&& distance(i.uv.y, PaintUv.y) < PaintBrushSize.y)
					{
						return tex2D(_CleanTex, i.uv);
					}
					return tex2D(_MainTex, i.uv);
				}
				ENDCG
			}
		}
}