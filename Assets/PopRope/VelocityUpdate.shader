Shader "PopRope/VelocityUpdate"
{
	Properties
	{
		VelocityData("VelocityData", 2D) = "red" {}
		PositionData("PositionData", 2D) = "white" {}

		AirFriction("AirFriction", Range(0,1) ) = 0.2
		GravityPerSecond("GravityPerSecond", Range(-5,5) ) = 0

		SpringStrength("SpringStrength", Range(0,1) ) = 1
		ChunkLength("ChunkLength", Range(0,2) ) = 0.5
		ChunkLengthToleranceMax("ChunkLengthToleranceMax", Range(0,1) ) = 0.5

		PrevOrNextForceWeight("PrevOrNextForceWeight", Range(0,1) ) = 0.5
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
			float AirFriction;
			float SpringStrength;
			float ChunkLength;
			float ChunkLengthToleranceMax;
			float PrevOrNextForceWeight;
			
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

			float3 GetPositionRC(int RopeIndex,int ChunkIndex)
			{
				float2 DataUv = float2( (float)ChunkIndex / PositionData_TexelSize.z, (float)RopeIndex / PositionData_TexelSize.w ); 
				float3 Position = PositionDataToPosition( tex2D( PositionData, DataUv ) );
				return Position;
			}

			float3 GetVelocity(float2 DataUv)
			{
				float3 Position = PositionDataToPosition( tex2D( VelocityData, DataUv ) );
				return Position;
			}

			float3 GetForceTowardsSpringPos(float3 JointPos,float3 SpringPos)
			{
				float3 Force = 0;

				//	work out where we WANT to be
				//	get vector from there to here (a normal)
				float3 PrevToPos = (JointPos - SpringPos);
				float LengthDiff = ( length( PrevToPos ) - ChunkLength);

				//	too close, then push out
				if ( LengthDiff < 0 )
				{
					PrevToPos *= -1;
					LengthDiff *= -1;
				}

				if ( LengthDiff > ChunkLength*ChunkLengthToleranceMax )
				{
					//	stretch it to the distance we're supposed to be
					PrevToPos = normalize(PrevToPos);
					float3 TargetPrevToPos = PrevToPos * ChunkLength;

					//	now get that as a [force] change
					float3 TargetDelta = TargetPrevToPos - PrevToPos;

					//	move this much to be at target
					Force += TargetDelta * SpringStrength;					
				}
			
				return Force;
			}

			float4 frag (v2f i) : SV_Target
			{
				int ChunkIndex = (int)i.ChunkIndex;
				int RopeIndex = (int)i.RopeIndex;
			//	if ( RopeIndex > 0 )
			//		return float4(1,0,0,1);
				/*
				float3 Debug = float3(0,0,0);
				Debug.x = ( ChunkIndex == 0 ) ? 1 : 0;
				Debug.y = ( RopeIndex == 0 ) ? 1 : 0;
				return float4(Debug,1);
				*/
				float3 Velocity = GetVelocity( i.DataUv );
				float3 Position = GetPositionRC( RopeIndex, ChunkIndex );

				//float3 Position = float3(0,GravityPerSecond,0);
				//float3 PosData = PositionToPositionData( Position );
				//return float4( PosData, 1 );

				float3 Force = float3(0,0,0);

				float TimeDelta = 1.0/10.0;
				//float TimeDelta = 1.0;
				//	air damping
				Force.y += GravityPerSecond;
				
				//	spring to neighbour
				if ( ChunkIndex > 0 && ChunkIndex<255 )
				{
					float3 Pos = GetPositionRC( RopeIndex, ChunkIndex );

					float3 PrevPos = GetPositionRC( RopeIndex, ChunkIndex-1 );
					float3 PrevForce = GetForceTowardsSpringPos( Pos, PrevPos );

					float3 NextPos = GetPositionRC( RopeIndex, ChunkIndex+1 );
					float3 NextForce = GetForceTowardsSpringPos( Pos, NextPos );

					float Weight = PrevOrNextForceWeight;
					if ( ChunkIndex < 4 )
						Weight = lerp( 0, PrevOrNextForceWeight, (float)ChunkIndex/4.0 );
					Force += lerp( PrevForce, NextForce, Weight ) * SpringStrength;
					//Force += PrevForce;
				}
		
		
				if ( GetRopeStatic(RopeIndex,ChunkIndex) )
				{
					Force = 0;
					Velocity = 0;
				}
				
				
				Velocity *= 1 - AirFriction;
				Velocity += Force * TimeDelta;


				
				float3 VelocityData = PositionToPositionData( Velocity );
				return float4(VelocityData,1);
			}
			ENDCG
		}
	}
}
