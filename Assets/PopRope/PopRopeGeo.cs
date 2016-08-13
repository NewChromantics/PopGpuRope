using UnityEngine;
using System.Collections;
using System.Collections.Generic;


[RequireComponent(typeof(MeshRenderer))]
public class PopRopeGeo : MonoBehaviour {

	public RenderTexture	PositionData;
	public Mesh				RopeMesh;

	void CreateCube(ref List<Vector3> Positions,ref List<Vector2> RopeDataUvs,ref List<int> Triangles,int RopeIndex,int ChunkIndex)
	{
		int FirstVertex = Positions.Count;
		Vector2 DataUv = new Vector2( RopeIndex, ChunkIndex );
		
		List<int> TempTriangles = new List<int>();

		System.Action<int, int, int> AddTriangle = (int v1, int v2, int v3) =>
		{
			TempTriangles.Add( v1 );
			TempTriangles.Add( v2 );
			TempTriangles.Add( v3 );
		};

		float Radius = 0.10f;
		float r = Radius;

		//	top, left, front
		Positions.Add( new Vector3(-r,-r,-r) );
		Positions.Add( new Vector3( r,-r,-r) );
		Positions.Add( new Vector3( r,-r, r) );
		Positions.Add( new Vector3(-r,-r, r) );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		int tlf = FirstVertex + 0;
		int trf = FirstVertex + 1;
		int trb = FirstVertex + 2;
		int tlb = FirstVertex + 3;

		Positions.Add( new Vector3(-r, r,-r) );
		Positions.Add( new Vector3( r, r,-r) );
		Positions.Add( new Vector3( r, r, r) );
		Positions.Add( new Vector3(-r, r, r) );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		RopeDataUvs.Add( DataUv );
		int blf = FirstVertex + 4;
		int brf = FirstVertex + 5;
		int brb = FirstVertex + 6;
		int blb = FirstVertex + 7;

		AddTriangle( tlf, trf, trb );
		AddTriangle( trb, tlb, tlf );

		AddTriangle( tlf, trf, brf );
		AddTriangle( brf, blf, tlf );

		AddTriangle( trf, trb, brb );
		AddTriangle( brb, brf, trf );

		AddTriangle( tlb, trb, brb );
		AddTriangle( brb, blb, tlb );

		AddTriangle( tlf, tlb, blb );
		AddTriangle( blb, blf, tlf );

		AddTriangle( blf, brf, brb );
		AddTriangle( brb, blb, blf );

		Triangles.AddRange( TempTriangles);
	}

	void Start()
	{ 
		int RopeCount = 1;//PositionData.height;
		int ChunkCount = PositionData.width;

		List<Vector3> Positions = new List<Vector3>();
		List<Vector2> RopeDataUvs = new List<Vector2>();
		List<int> Triangles = new List<int>();

		for (int r = 0; r < RopeCount; r++)
		{
			for (int c = 0; c < ChunkCount; c++)
			{
				CreateCube( ref Positions, ref RopeDataUvs, ref Triangles, r, c );
			}
		}

		RopeMesh = new Mesh();
		RopeMesh.SetVertices( Positions );
		RopeMesh.SetUVs( 0, RopeDataUvs );
		RopeMesh.SetIndices( Triangles.ToArray(), MeshTopology.Triangles, 0 );
		RopeMesh.name = "RopeMesh " + RopeCount + "x" + ChunkCount;

		var mf = GetComponent<MeshFilter>();
		mf.mesh = RopeMesh;
	}



}
