using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PopRope : MonoBehaviour {

	public RenderTexture PositionData;
	public Material PositionInit;
	public Material PositionUpdate;

	void Start () {

		Graphics.Blit (null, PositionData, PositionInit);
	
	}
	
	void Update () {

		if (PositionUpdate != null) {
			//	run through update shaders
			var PositionDataLast = RenderTexture.GetTemporary (PositionData.width, PositionData.height, 0);

			Graphics.Blit (PositionData, PositionDataLast);

			//	send old pos to material
			PositionUpdate.SetTexture ("PositionDataLast", PositionDataLast);
			Graphics.Blit (null, PositionData, PositionUpdate);
		}
	}
}
