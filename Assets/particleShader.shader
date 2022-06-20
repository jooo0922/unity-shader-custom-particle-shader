Shader "Custom/particleShader"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5) // �⺻���� 0.5(ȸ��)����, ����ڷκ��� �Է°��� �޾� particle �� ��ü ������ ������.
        _MainTex ("Albedo (RGB)", 2D) = "white" {} // ��ƼŬ �ؽ��ĸ� �޾Ƽ� ������ ��Ƴ��� �������̽� �߰�

        // ���� ���� ������ ����ڷκ��� �Է¹��� �� �ִ� �������̽� �߰�
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend Mode", Float) = 10
    }
    SubShader
    {
        // Tags ������ Transparent �� �ٲ����ν�, ���� ���̴��� '���� ���� ���̴�(������ ���̴�)'�� ��ȯ��.
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector" = "True"} // ����Ƽ ���� �������� (���� �׸��� ���� �� ���)�� �������� �ʵ��� IgnoreProjector �� Ȱ��ȭ��.
        zwrite off // ���� ���� ���̴������� z���۸� ��Ȱ��ȭ�ؾ� ��. �� ������ p.463 - 464 ����
        // blend SrcAlpha One // ���� ���� ������ 'Additive' �� ����. -> ���� 'Add ���' ��� �θ��� ���� ���. ��ġ�� ��ĥ���� �������, ���� ȿ�� � �����.
        blend [_SrcBlend] [_DstBlend] // ����ڷκ��� �Է¹��� ���� ���� ������ ��������.
        cull off // �� �߷����⸦ �����Ͽ� ��� ������ ó����.

        CGPROGRAM

        // �ƹ��� ������ ���� �ʴ� Ŀ���� ����Ʈ �Լ� �߰�
        // ���� ����Ƽ�� ���ǽ� ���̴����� �⺻������ ������ ���̴�("RenderType"="Opaque") �� ���İ��� 1.0���� ������Ŵ. �̰� ������Ű�� ���� keepalpha �� ���� ��.
        #pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow // ���ǽ� ���̴� ���� �� �ڵ����� �����Ǵ� �߰� ���̴����� �������� �ʵ��� �ϴ� ������ �߰���.

        sampler2D _MainTex;
        float4 _TintColor;

        struct Input
        {
            float2 uv_MainTex;

            // ���ؽ� �÷����� ����ü�� ������. 
            // �� ���� ��ƼŬ ���� ������� ��ƼŬ �÷� �ɼ��� �����. 
            // ��ƼŬ �÷� �ɼ��� å�� ���������� ���� ���� ����������,
            // Particle System > Inspector �ǿ��� Start Color �� �������ָ� �ش� ������ ��ƼŬ �÷����� ����Ǵ� �� �� �� ����. 
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            // 0.5(ȸ��)�� �⺻���� _TintColor �� 2�� �������ν�,
            // �⺻���� ��� �׳� c�� 1�� �������� ������ ���� ������,
            // 0.5���� ū ���� ���� ��� 2�� ���� ���� 1���� Ŀ���״� ��ƼŬ ������ ����� ���̰�,
            // 0.5���� ���� ���� ���� ��� 2�� ���� ���� 1���� �����״� ��ƼŬ ������ ��ο����鼭 ��ƼŬ alpha ���� ���� 0�� ���������
            // �ᱹ ��ƼŬ�� ���� �������� ���� -> �̷� ������ ��ƼŬ�� ��ü ������ �����ϴ� ��!
            c = c * 2 * _TintColor * IN.color;
            o.Emission = c.rgb; // ���� ���� ���꿡���� ������ Emission �� �ؼ����� �־��� ��.
            o.Alpha = c.a;
        }

        // �ƹ��� ������ ���� �ʴ� Ŀ���� ����Ʈ �Լ� -> ���� �ʿ������, �̷��� ������� �������� ���ǽ� ���̴��� �������.
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit" // �ش� ���̴� ���꿡 �������� ���, �Ǵ� '�׸��� ����'�� ������ ����Ƽ ���� ���̴� ����
}
