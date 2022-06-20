Shader "Custom/particleShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {} // 파티클 텍스쳐를 받아서 변수에 담아놓을 인터페이스 추가
    }
    SubShader
    {
        // Tags 설정을 Transparent 로 바꿈으로써, 현재 쉐이더를 '알파 블렌드 쉐이더(반투명 쉐이더)'로 변환함.
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        zwrite off // 알파 블렌딩 쉐이더에서는 z버퍼를 비활성화해야 함. 그 이유는 p.463 - 464 참고
        blend SrcAlpha One // 블렌딩 팩터 연산을 'Additive' 로 적용. -> 흔히 'Add 모드' 라고 부르는 블렌딩 방식. 겹치면 겹칠수록 밝아져서, 폭발 효과 등에 사용함.

        CGPROGRAM

        // Lambert 라이트 기본형으로 시작
        #pragma surface surf Lambert keepalpha // 원래 유니티는 서피스 셰이더에서 기본적으로 불투명 쉐이더("RenderType"="Opaque") 의 알파값을 1.0으로 고정시킴. 이걸 해제시키기 위해 keepalpha 를 써준 것.

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Emission = c.rgb; // 블렌딩 팩터 연산에서는 가급적 Emission 에 텍셀값을 넣어줄 것.
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit" // 해당 셰이더 연산에 실패했을 경우, 또는 '그림자 연산'에 적용할 유니티 내장 셰이더 선언
}
