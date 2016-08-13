Shader "PopRope/PositionUpdate"
{
	Properties
	{
		VelocityData("VelocityData", 2D) = "white" {}
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
				float4 vertex : SV_POSITION;
				float RopeIndex : TEXCOORD0;
				float ChunkIndex : TEXCOORD1;
				float2 DataUv : TEXCOORD2;
			};

			sampler2D PositionData;
			float4 PositionData_TexelSize;
			sampler2D VelocityData;
			float4 VelocityData_TexelSize;
			float GravityPerSecond;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				o.RopeIndex = (int)(v.uv.y * PositionData_TexelSize.w);
				o.ChunkIndex = (int)(v.uv.x * PositionData_TexelSize.z);

				//	this HAS to match input as we're reading & writing back to the same place
				o.DataUv = v.uv;
				return o;
			}

			float3 GetPosition(float2 DataUv)
			{
				float3 Position = PositionDataToPosition( tex2D( PositionData, DataUv ) );
				return Position;
			}

			float3 GetVelocity(float2 DataUv)
			{
				float3 Position = PositionDataToPosition( tex2D( VelocityData, DataUv ) );
				return Position;
			}


			fixed4 frag (v2f i) : SV_Target
			{
				int ChunkIndex = (int)i.ChunkIndex;
				int RopeIndex = (int)i.RopeIndex;
				if ( RopeIndex > 0 )
					return float4(1,0,0,1);
				/*
				float3 Debug = float3(0,0,0);
				Debug.x = ( ChunkIndex == 0 ) ? 1 : 0;
				Debug.y = ( RopeIndex == 0 ) ? 1 : 0;
				return float4(Debug,1);
				*/

				float3 Velocity = GetVelocity( i.DataUv );
				float3 Position = GetPosition( i.DataUv );

				/*
				if ( GetRopeStatic(i.RopeIndex,i.ChunkIndex) )
				{
					Position = 0;
				}
				Position = float3(0,i.ChunkIndex,0);
				*/
				/*
				if ( !GetRopeStatic(RopeIndex,ChunkIndex) )
				{
					//	move
					Position += Velocity;

					//	collision
					if ( Position.y < 0 )
						Position.y = 0;
				}

				//Position = Velocity;
				*/
				Position += Velocity;

				//	collision
				if ( Position.y < 0 )
					Position.y = 0;

				float3 PosData = PositionToPositionData( Position );
				return float4(PosData,1);
			}
			ENDCG
		}
	}
}
