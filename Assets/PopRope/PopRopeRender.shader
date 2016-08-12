Shader "Unlit/PopRopeRender"
{
	Properties
	{
		PositionData("PositionData", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "../PopRope/PopRope.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 LocalPos : TEXCOORD1;
			};

			sampler2D PositionData;
			float4 PositionData_TexelSize;

		

			v2f vert (appdata v)
			{
				v2f o;

				float3 LocalPos = v.vertex;

				//	gr: each vertex needs to work out which pos to use.
				float VertexIndex = LocalPos.y;

				float2 PosUv = float2( 0, LocalPos.y );
				LocalPos += PositionDataToPosition( tex2Dlod( PositionData, float4( PosUv, 0, 0 ) ) );

				o.vertex = mul(UNITY_MATRIX_MVP, float4(LocalPos,1) );

				o.uv = v.uv;
				o.LocalPos = LocalPos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return float4( i.LocalPos.x, i.LocalPos.y, i.LocalPos.z, 1 );
			}
			ENDCG
		}
	}
}
