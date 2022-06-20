Shader "Custom/particleShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {} // ��ƼŬ �ؽ��ĸ� �޾Ƽ� ������ ��Ƴ��� �������̽� �߰�
    }
    SubShader
    {
        // Tags ������ Transparent �� �ٲ����ν�, ���� ���̴��� '���� ���� ���̴�(������ ���̴�)'�� ��ȯ��.
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        zwrite off // ���� ���� ���̴������� z���۸� ��Ȱ��ȭ�ؾ� ��. �� ������ p.463 - 464 ����
        blend SrcAlpha One // ���� ���� ������ 'Additive' �� ����. -> ���� 'Add ���' ��� �θ��� ���� ���. ��ġ�� ��ĥ���� �������, ���� ȿ�� � �����.

        CGPROGRAM

        // Lambert ����Ʈ �⺻������ ����
        #pragma surface surf Lambert keepalpha // ���� ����Ƽ�� ���ǽ� ���̴����� �⺻������ ������ ���̴�("RenderType"="Opaque") �� ���İ��� 1.0���� ������Ŵ. �̰� ������Ű�� ���� keepalpha �� ���� ��.

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Emission = c.rgb; // ���� ���� ���꿡���� ������ Emission �� �ؼ����� �־��� ��.
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit" // �ش� ���̴� ���꿡 �������� ���, �Ǵ� '�׸��� ����'�� ������ ����Ƽ ���� ���̴� ����
}
