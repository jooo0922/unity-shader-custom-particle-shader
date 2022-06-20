Shader "Custom/particleShader"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5) // 기본값은 0.5(회색)으로, 사용자로부터 입력값을 받아 particle 의 전체 색상을 제어함.
        _MainTex ("Albedo (RGB)", 2D) = "white" {} // 파티클 텍스쳐를 받아서 변수에 담아놓을 인터페이스 추가

        // 블렌드 팩터 연산을 사용자로부터 입력받을 수 있는 인터페이스 추가
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend Mode", Float) = 10
    }
    SubShader
    {
        // Tags 설정을 Transparent 로 바꿈으로써, 현재 쉐이더를 '알파 블렌드 쉐이더(반투명 쉐이더)'로 변환함.
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector" = "True"} // 유니티 내장 프로젝터 (동전 그림자 만들 때 사용)에 반응하지 않도록 IgnoreProjector 를 활성화함.
        zwrite off // 알파 블렌딩 쉐이더에서는 z버퍼를 비활성화해야 함. 그 이유는 p.463 - 464 참고
        // blend SrcAlpha One // 블렌딩 팩터 연산을 'Additive' 로 적용. -> 흔히 'Add 모드' 라고 부르는 블렌딩 방식. 겹치면 겹칠수록 밝아져서, 폭발 효과 등에 사용함.
        blend [_SrcBlend] [_DstBlend] // 사용자로부터 입력받은 블렌드 팩터 연산을 지정해줌.
        cull off // 면 추려내기를 해제하여 양면 렌더링 처리함.

        CGPROGRAM

        // 아무런 연산을 하지 않는 커스텀 라이트 함수 추가
        // 원래 유니티는 서피스 셰이더에서 기본적으로 불투명 쉐이더("RenderType"="Opaque") 의 알파값을 1.0으로 고정시킴. 이걸 해제시키기 위해 keepalpha 를 써준 것.
        #pragma surface surf nolight keepalpha noforwardadd nolightmap noambient novertexlights noshadow // 서피스 쉐이더 생성 시 자동으로 생성되는 추가 쉐이더들을 생성하지 않도록 하는 구문들 추가함.

        sampler2D _MainTex;
        float4 _TintColor;

        struct Input
        {
            float2 uv_MainTex;

            // 버텍스 컬러값을 구조체에 정의함. 
            // 이 값을 파티클 색상에 곱해줘야 파티클 컬러 옵션이 적용됨. 
            // 파티클 컬러 옵션은 책의 예제에서는 딱히 지정 안해줬지만,
            // Particle System > Inspector 탭에서 Start Color 를 지정해주면 해당 색상이 파티클 컬러에도 적용되는 걸 볼 수 있음. 
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            // 0.5(회색)이 기본값인 _TintColor 에 2를 곱함으로써,
            // 기본값일 경우 그냥 c에 1이 곱해져서 원래의 색이 나오고,
            // 0.5보다 큰 값을 받을 경우 2를 곱한 값은 1보다 커질테니 파티클 색상이 밝아질 것이고,
            // 0.5보다 작은 값을 받을 경우 2를 곱한 값은 1보다 작을테니 파티클 색상은 어두워지면서 파티클 alpha 값도 같이 0에 가까워져서
            // 결국 파티클이 점점 투명해질 것임 -> 이런 식으로 파티클의 전체 색상을 조정하는 것!
            c = c * 2 * _TintColor * IN.color;
            o.Emission = c.rgb; // 블렌딩 팩터 연산에서는 가급적 Emission 에 텍셀값을 넣어줄 것.
            o.Alpha = c.a;
        }

        // 아무런 연산을 하지 않는 커스텀 라이트 함수 -> 원래 필요없지만, 이렇게 껍데기라도 만들어줘야 서피스 쉐이더가 만들어짐.
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit" // 해당 셰이더 연산에 실패했을 경우, 또는 '그림자 연산'에 적용할 유니티 내장 셰이더 선언
}
