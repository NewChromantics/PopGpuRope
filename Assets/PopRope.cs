using UnityEngine;
using System.Collections;

public class PopRope : MonoBehaviour {

	public RenderTexture PositionData;
	public Material PositionInit;

	void Start () {

		Graphics.Blit (null, PositionData, PositionInit);
	
	}
	
	void Update () {
	
	}
}
