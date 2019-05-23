using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Geometry : MonoBehaviour {

	public int count = 10000;
	public Vector2 segments = Vector2.one;

	void Start () {
		Vector3[] positions = new Vector3[count];
		for (int index = 0; index < count; ++index) positions[index] = Random.onUnitSphere * 100f;
		GetComponent<MeshFilter>().mesh = Geometry.Particles(positions, null, null, segments.x, segments.y);
	}

	public static Mesh Particles (Vector3[] positions, Color[] colors_ = null, Vector3[] normals_ = null, float sliceX = 1f, float sliceY = 1f) {
		Vector2 faces = new Vector2(sliceX+1f, sliceY+1f);
		int amount = positions.Length;
		int vertexCount = (int)(faces.x * faces.y);
		int totalVertices = amount * vertexCount;
		int mapIndex = 0;
		int count = totalVertices;
		List<Vector3> vertices = new List<Vector3>();
		List<Vector3> normals = new List<Vector3>();
		List<Color> colors = new List<Color>();
		List<Vector2> anchors = new List<Vector2>();
		List<Vector2> quantities = new List<Vector2>();
		List<int> indices = new List<int>();
		int vIndex = 0;
		for (int index = 0; index < count/(faces.x*faces.y); ++index) {
			Vector3 position = positions[mapIndex];
			Vector3 normal = Vector3.up;
			Color color = Color.white;
			if (colors_ != null) color = colors_[mapIndex];
			if (normals_ != null) normal = normals_[mapIndex];
			for (int y = 0; y < faces.y; ++y) {
				for (int x = 0; x < faces.x; ++x) {
					quantities.Add(new Vector2(mapIndex/(float)amount,mapIndex));
					vertices.Add(position);
					if (normals_ != null) normals.Add(normal);
					if (colors_ != null) colors.Add(color);
					anchors.Add(new Vector2(((float)x/(float)sliceX)*2f-1f, ((float)y/(float)sliceY)*2f-1f));
				}
			}
			for (int y = 0; y < sliceY; ++y) {
				for (int x = 0; x < sliceX; ++x) {
					indices.Add(vIndex);
					indices.Add(vIndex+1);
					indices.Add(vIndex+1+(int)sliceX);
					indices.Add(vIndex+1+(int)sliceX);
					indices.Add(vIndex+1);
					indices.Add(vIndex+2+(int)sliceX);
					vIndex += 1;
				}
				vIndex += 1;
			}
			vIndex += (int)faces.x;
			++mapIndex;
		}
		Mesh mesh = new Mesh();
		mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
		mesh.vertices = vertices.ToArray();
		if (normals_ != null) mesh.normals = normals.ToArray();
		if (colors_ != null) mesh.colors = colors.ToArray();
		mesh.uv = anchors.ToArray();
		mesh.uv2 = quantities.ToArray();
		mesh.SetTriangles(indices.ToArray(), 0);
		mesh.RecalculateBounds();
		return mesh;
	}
}
