import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

class WordChainGameScreen extends StatefulWidget {
  const WordChainGameScreen({super.key});
  @override
  State<WordChainGameScreen> createState() => _WordChainGameScreenState();
}

class _WordChainGameScreenState extends State<WordChainGameScreen> {
  final FlutterTts _tts = FlutterTts();

  final List<Map<String, dynamic>> _allRounds = [
    // ── 사 ──
    {'chain': '사과', 'options': ['과자', '나무', '하늘'], 'answer': '과자', 'hint': '사과 → 과___'},
    {'chain': '사탕', 'options': ['탕수육', '바다', '구름'], 'answer': '탕수육', 'hint': '사탕 → 탕___'},
    {'chain': '사자', 'options': ['자동차', '가방', '바람'], 'answer': '자동차', 'hint': '사자 → 자___'},
    {'chain': '사슴', 'options': ['슴베', '하늘', '강'], 'answer': '슴베', 'hint': '사슴 → 슴___'},
    {'chain': '사막', 'options': ['막걸리', '산', '물'], 'answer': '막걸리', 'hint': '사막 → 막___'},
    // ── 과 ──
    {'chain': '과자', 'options': ['자동차', '가방', '파도'], 'answer': '자동차', 'hint': '과자 → 자___'},
    {'chain': '과일', 'options': ['일기', '하늘', '강'], 'answer': '일기', 'hint': '과일 → 일___'},
    {'chain': '과학', 'options': ['학교', '바다', '구름'], 'answer': '학교', 'hint': '과일 → 학___'},
    // ── 자 ──
    {'chain': '자동차', 'options': ['차표', '나무', '하늘'], 'answer': '차표', 'hint': '자동차 → 차___'},
    {'chain': '자전거', 'options': ['거미', '산', '물'], 'answer': '거미', 'hint': '자전거 → 거___'},
    {'chain': '자연', 'options': ['연필', '바다', '바람'], 'answer': '연필', 'hint': '자연 → 연___'},
    {'chain': '자석', 'options': ['석탄', '하늘', '강'], 'answer': '석탄', 'hint': '자석 → 석___'},
    // ── 차 ──
    {'chain': '차표', 'options': ['표범', '바다', '구름'], 'answer': '표범', 'hint': '차표 → 표___'},
    {'chain': '차도', 'options': ['도서관', '하늘', '강'], 'answer': '도서관', 'hint': '차도 → 도___'},
    {'chain': '차례', 'options': ['례절', '산', '물'], 'answer': '례절', 'hint': '차례 → 례___'},
    // ── 나 ──
    {'chain': '나무', 'options': ['무지개', '하늘', '바람'], 'answer': '무지개', 'hint': '나무 → 무___'},
    {'chain': '나비', 'options': ['비행기', '하늘', '달'], 'answer': '비행기', 'hint': '나비 → 비___'},
    {'chain': '나라', 'options': ['라면', '산', '강'], 'answer': '라면', 'hint': '나라 → 라___'},
    {'chain': '나침반', 'options': ['반지', '하늘', '바다'], 'answer': '반지', 'hint': '나침반 → 반___'},
    // ── 무 ──
    {'chain': '무지개', 'options': ['개나리', '구름', '강'], 'answer': '개나리', 'hint': '무지개 → 개___'},
    {'chain': '무궁화', 'options': ['화분', '산', '물'], 'answer': '화분', 'hint': '무궁화 → 화___'},
    {'chain': '무릎', 'options': ['릎뼈', '하늘', '바람'], 'answer': '릎뼈', 'hint': '무릎 → 릎___'},
    // ── 개 ──
    {'chain': '개나리', 'options': ['리본', '바다', '산'], 'answer': '리본', 'hint': '개나리 → 리___'},
    {'chain': '개구리', 'options': ['리본', '하늘', '강'], 'answer': '리본', 'hint': '개구리 → 리___'},
    {'chain': '개미', 'options': ['미역', '산', '물'], 'answer': '미역', 'hint': '개미 → 미___'},
    // ── 비 ──
    {'chain': '비행기', 'options': ['기차', '배', '버스'], 'answer': '기차', 'hint': '비행기 → 기___'},
    {'chain': '비빔밥', 'options': ['밥솥', '하늘', '강'], 'answer': '밥솥', 'hint': '비빔밥 → 밥___'},
    {'chain': '비둘기', 'options': ['기차', '산', '물'], 'answer': '기차', 'hint': '비둘기 → 기___'},
    {'chain': '비누', 'options': ['누나', '바다', '구름'], 'answer': '누나', 'hint': '비누 → 누___'},
    // ── 기 ──
    {'chain': '기차', 'options': ['차도', '열차', '사람'], 'answer': '차도', 'hint': '기차 → 차___'},
    {'chain': '기린', 'options': ['린스', '하늘', '강'], 'answer': '린스', 'hint': '기린 → 린___'},
    {'chain': '기름', 'options': ['름지', '산', '물'], 'answer': '름지', 'hint': '기름 → 름___'},
    {'chain': '기둥', 'options': ['둥지', '바다', '바람'], 'answer': '둥지', 'hint': '기둥 → 둥___'},
    // ── 도 ──
    {'chain': '도서관', 'options': ['관람', '하늘', '강'], 'answer': '관람', 'hint': '도서관 → 관___'},
    {'chain': '도마뱀', 'options': ['뱀장어', '산', '물'], 'answer': '뱀장어', 'hint': '도마뱀 → 뱀___'},
    {'chain': '도토리', 'options': ['리본', '바다', '구름'], 'answer': '리본', 'hint': '도토리 → 리___'},
    {'chain': '도넛', 'options': ['넛트', '하늘', '강'], 'answer': '넛트', 'hint': '도넛 → 넛___'},
    // ── 표 ──
    {'chain': '표범', 'options': ['범인', '강물', '산'], 'answer': '범인', 'hint': '표범 → 범___'},
    {'chain': '표지판', 'options': ['판소리', '하늘', '물'], 'answer': '판소리', 'hint': '표지판 → 판___'},
    // ── 범 ──
    {'chain': '범인', 'options': ['인삼', '바다', '바람'], 'answer': '인삼', 'hint': '범인 → 인___'},
    {'chain': '범고래', 'options': ['래지', '산', '강'], 'answer': '래지', 'hint': '범고래 → 래___'},
    // ── 인 ──
    {'chain': '인삼', 'options': ['삼겹살', '하늘', '구름'], 'answer': '삼겹살', 'hint': '인삼 → 삼___'},
    {'chain': '인형', 'options': ['형제', '바다', '강'], 'answer': '형제', 'hint': '인형 → 형___'},
    {'chain': '인어', 'options': ['어머니', '산', '물'], 'answer': '어머니', 'hint': '인어 → 어___'},
    // ── 삼 ──
    {'chain': '삼겹살', 'options': ['살구', '하늘', '바람'], 'answer': '살구', 'hint': '삼겹살 → 살___'},
    {'chain': '삼각형', 'options': ['형제', '산', '강'], 'answer': '형제', 'hint': '삼각형 → 형___'},
    // ── 살 ──
    {'chain': '살구', 'options': ['구름', '바다', '산'], 'answer': '구름', 'hint': '살구 → 구___'},
    // ── 구 ──
    {'chain': '구름', 'options': ['름직', '하늘', '강'], 'answer': '름직', 'hint': '구름 → 름___'},
    {'chain': '구멍', 'options': ['멍게', '산', '물'], 'answer': '멍게', 'hint': '구멍 → 멍___'},
    {'chain': '구두', 'options': ['두부', '바다', '바람'], 'answer': '두부', 'hint': '구두 → 두___'},
    {'chain': '구석', 'options': ['석류', '하늘', '구름'], 'answer': '석류', 'hint': '구석 → 석___'},
    // ── 두 ──
    {'chain': '두부', 'options': ['부엌', '산', '강'], 'answer': '부엌', 'hint': '두부 → 부___'},
    {'chain': '두꺼비', 'options': ['비누', '하늘', '물'], 'answer': '비누', 'hint': '두꺼비 → 비___'},
    {'chain': '두더지', 'options': ['지도', '바다', '바람'], 'answer': '지도', 'hint': '두더지 → 지___'},
    // ── 부 ──
    {'chain': '부엌', 'options': ['엌째', '산', '강'], 'answer': '엌째', 'hint': '부엌 → 엌___'},
    {'chain': '부채', 'options': ['채소', '하늘', '구름'], 'answer': '채소', 'hint': '부채 → 채___'},
    {'chain': '부모', 'options': ['모자', '바다', '물'], 'answer': '모자', 'hint': '부모 → 모___'},
    // ── 모 ──
    {'chain': '모자', 'options': ['자두', '하늘', '강'], 'answer': '자두', 'hint': '모자 → 자___'},
    {'chain': '모래', 'options': ['래지', '산', '바람'], 'answer': '래지', 'hint': '모래 → 래___'},
    {'chain': '모기', 'options': ['기린', '바다', '구름'], 'answer': '기린', 'hint': '모기 → 기___'},
    // ── 바 ──
    {'chain': '바나나', 'options': ['나비', '가방', '물'], 'answer': '나비', 'hint': '바나나 → 나___'},
    {'chain': '바다', 'options': ['다람쥐', '하늘', '산'], 'answer': '다람쥐', 'hint': '바다 → 다___'},
    {'chain': '바람', 'options': ['람보', '구름', '강'], 'answer': '람보', 'hint': '바람 → 람___'},
    {'chain': '바위', 'options': ['위성', '바다', '물'], 'answer': '위성', 'hint': '바위 → 위___'},
    {'chain': '바지', 'options': ['지구', '하늘', '바람'], 'answer': '지구', 'hint': '바지 → 지___'},
    // ── 다 ──
    {'chain': '다람쥐', 'options': ['쥐며느리', '산', '강'], 'answer': '쥐며느리', 'hint': '다람쥐 → 쥐___'},
    {'chain': '다리미', 'options': ['미역', '하늘', '구름'], 'answer': '미역', 'hint': '다리미 → 미___'},
    {'chain': '다슬기', 'options': ['기름', '바다', '물'], 'answer': '기름', 'hint': '다슬기 → 기___'},
    // ── 하 ──
    {'chain': '하늘', 'options': ['늘보', '산', '강'], 'answer': '늘보', 'hint': '하늘 → 늘___'},
    {'chain': '하마', 'options': ['마을', '바다', '바람'], 'answer': '마을', 'hint': '하마 → 마___'},
    {'chain': '하루', 'options': ['루비', '하늘', '구름'], 'answer': '루비', 'hint': '하루 → 루___'},
    // ── 마 ──
    {'chain': '마을', 'options': ['을지로', '산', '강'], 'answer': '을지로', 'hint': '마을 → 을___'},
    {'chain': '마차', 'options': ['차도', '바다', '물'], 'answer': '차도', 'hint': '마차 → 차___'},
    {'chain': '마늘', 'options': ['늘보', '하늘', '바람'], 'answer': '늘보', 'hint': '마늘 → 늘___'},
    // ── 가 ──
    {'chain': '가방', 'options': ['방귀', '산', '구름'], 'answer': '방귀', 'hint': '가방 → 방___'},
    {'chain': '가위', 'options': ['위성', '바다', '강'], 'answer': '위성', 'hint': '가위 → 위___'},
    {'chain': '가을', 'options': ['을지로', '하늘', '물'], 'answer': '을지로', 'hint': '가을 → 을___'},
    {'chain': '가수', 'options': ['수박', '산', '바람'], 'answer': '수박', 'hint': '가수 → 수___'},
    // ── 방 ──
    {'chain': '방귀', 'options': ['귀신', '하늘', '강'], 'answer': '귀신', 'hint': '방귀 → 귀___'},
    {'chain': '방울', 'options': ['울음', '바다', '구름'], 'answer': '울음', 'hint': '방울 → 울___'},
    // ── 귀 ──
    {'chain': '귀신', 'options': ['신발', '산', '물'], 'answer': '신발', 'hint': '귀신 → 신___'},
    {'chain': '귀뚜라미', 'options': ['미역', '하늘', '바람'], 'answer': '미역', 'hint': '귀뚜라미 → 미___'},
    // ── 신 ──
    {'chain': '신발', 'options': ['발가락', '바다', '강'], 'answer': '발가락', 'hint': '신발 → 발___'},
    {'chain': '신문', 'options': ['문어', '하늘', '구름'], 'answer': '문어', 'hint': '신문 → 문___'},
    // ── 발 ──
    {'chain': '발가락', 'options': ['락지', '산', '물'], 'answer': '락지', 'hint': '발가락 → 락___'},
    {'chain': '발바닥', 'options': ['닥나무', '바다', '바람'], 'answer': '닥나무', 'hint': '발바닥 → 닥___'},
    // ── 문 ──
    {'chain': '문어', 'options': ['어머니', '하늘', '강'], 'answer': '어머니', 'hint': '문어 → 어___'},
    {'chain': '문방구', 'options': ['구름', '산', '물'], 'answer': '구름', 'hint': '문방구 → 구___'},
    // ── 어 ──
    {'chain': '어머니', 'options': ['니트', '바다', '구름'], 'answer': '니트', 'hint': '어머니 → 니___'},
    {'chain': '어린이', 'options': ['이불', '하늘', '바람'], 'answer': '이불', 'hint': '어린이 → 이___'},
    // ── 이 ──
    {'chain': '이불', 'options': ['불꽃', '산', '강'], 'answer': '불꽃', 'hint': '이불 → 불___'},
    {'chain': '이마', 'options': ['마을', '바다', '물'], 'answer': '마을', 'hint': '이마 → 마___'},
    {'chain': '이슬', 'options': ['슬리퍼', '하늘', '구름'], 'answer': '슬리퍼', 'hint': '이슬 → 슬___'},
    // ── 불 ──
    {'chain': '불꽃', 'options': ['꽃게', '산', '바람'], 'answer': '꽃게', 'hint': '불꽃 → 꽃___'},
    {'chain': '불개미', 'options': ['미역', '하늘', '강'], 'answer': '미역', 'hint': '불개미 → 미___'},
    // ── 꽃 ──
    {'chain': '꽃게', 'options': ['게장', '바다', '물'], 'answer': '게장', 'hint': '꽃게 → 게___'},
    {'chain': '꽃잎', 'options': ['잎사귀', '산', '구름'], 'answer': '잎사귀', 'hint': '꽃잎 → 잎___'},
    // ── 수 ──
    {'chain': '수박', 'options': ['박쥐', '하늘', '강'], 'answer': '박쥐', 'hint': '수박 → 박___'},
    {'chain': '수달', 'options': ['달팽이', '바다', '물'], 'answer': '달팽이', 'hint': '수달 → 달___'},
    {'chain': '수건', 'options': ['건포도', '산', '바람'], 'answer': '건포도', 'hint': '수건 → 건___'},
    {'chain': '수영', 'options': ['영어', '하늘', '구름'], 'answer': '영어', 'hint': '수영 → 영___'},
    // ── 박 ──
    {'chain': '박쥐', 'options': ['쥐며느리', '산', '강'], 'answer': '쥐며느리', 'hint': '박쥐 → 쥐___'},
    {'chain': '박수', 'options': ['수박', '바다', '물'], 'answer': '수박', 'hint': '박수 → 수___'},
    // ── 달 ──
    {'chain': '달팽이', 'options': ['이불', '하늘', '바람'], 'answer': '이불', 'hint': '달팽이 → 이___'},
    {'chain': '달걀', 'options': ['걀쭉', '산', '구름'], 'answer': '걀쭉', 'hint': '달걀 → 걀___'},
    {'chain': '달력', 'options': ['력사', '바다', '강'], 'answer': '력사', 'hint': '달력 → 력___'},
    // ── 지 ──
    {'chain': '지구', 'options': ['구름', '하늘', '물'], 'answer': '구름', 'hint': '지구 → 구___'},
    {'chain': '지도', 'options': ['도서관', '산', '바람'], 'answer': '도서관', 'hint': '지도 → 도___'},
    {'chain': '지갑', 'options': ['갑옷', '바다', '구름'], 'answer': '갑옷', 'hint': '지갑 → 갑___'},
    // ── 갑 ──
    {'chain': '갑옷', 'options': ['옷걸이', '하늘', '강'], 'answer': '옷걸이', 'hint': '갑옷 → 옷___'},
    // ── 옷 ──
    {'chain': '옷걸이', 'options': ['이슬', '산', '물'], 'answer': '이슬', 'hint': '옷걸이 → 이___'},
    // ── 라 ──
    {'chain': '라면', 'options': ['면도기', '바다', '바람'], 'answer': '면도기', 'hint': '라면 → 면___'},
    {'chain': '라디오', 'options': ['오리', '하늘', '구름'], 'answer': '오리', 'hint': '라디오 → 오___'},
    // ── 면 ──
    {'chain': '면도기', 'options': ['기차', '산', '강'], 'answer': '기차', 'hint': '면도기 → 기___'},
    // ── 오 ──
    {'chain': '오리', 'options': ['리본', '바다', '물'], 'answer': '리본', 'hint': '오리 → 리___'},
    {'chain': '오렌지', 'options': ['지구', '하늘', '바람'], 'answer': '지구', 'hint': '오렌지 → 지___'},
    {'chain': '오이', 'options': ['이마', '산', '구름'], 'answer': '이마', 'hint': '오이 → 이___'},
    // ── 리 ──
    {'chain': '리본', 'options': ['본보기', '하늘', '강'], 'answer': '본보기', 'hint': '리본 → 본___'},
    // ── 본 ──
    {'chain': '본보기', 'options': ['기린', '바다', '물'], 'answer': '기린', 'hint': '본보기 → 기___'},
    // ── 학 ──
    {'chain': '학교', 'options': ['교실', '산', '바람'], 'answer': '교실', 'hint': '학교 → 교___'},
    {'chain': '학생', 'options': ['생선', '하늘', '구름'], 'answer': '생선', 'hint': '학생 → 생___'},
    // ── 교 ──
    {'chain': '교실', 'options': ['실내', '바다', '강'], 'answer': '실내', 'hint': '교실 → 실___'},
    // ── 생 ──
    {'chain': '생선', 'options': ['선생님', '하늘', '물'], 'answer': '선생님', 'hint': '생선 → 선___'},
    {'chain': '생강', 'options': ['강물', '산', '바람'], 'answer': '강물', 'hint': '생강 → 강___'},
    // ── 선 ──
    {'chain': '선생님', 'options': ['님비', '바다', '구름'], 'answer': '님비', 'hint': '선생님 → 님___'},
    {'chain': '선물', 'options': ['물고기', '하늘', '강'], 'answer': '물고기', 'hint': '선물 → 물___'},
    // ── 물 ──
    {'chain': '물고기', 'options': ['기차', '산', '바람'], 'answer': '기차', 'hint': '물고기 → 기___'},
    {'chain': '물감', 'options': ['감자', '바다', '구름'], 'answer': '감자', 'hint': '물감 → 감___'},
    // ── 감 ──
    {'chain': '감자', 'options': ['자두', '하늘', '물'], 'answer': '자두', 'hint': '감자 → 자___'},
    {'chain': '감기', 'options': ['기린', '산', '강'], 'answer': '기린', 'hint': '감기 → 기___'},
    // ── 강 ──
    {'chain': '강물', 'options': ['물감', '바다', '바람'], 'answer': '물감', 'hint': '강물 → 물___'},
    {'chain': '강아지', 'options': ['지도', '하늘', '구름'], 'answer': '지도', 'hint': '강아지 → 지___'},
    // ── 연 ──
    {'chain': '연필', 'options': ['필통', '산', '강'], 'answer': '필통', 'hint': '연필 → 필___'},
    {'chain': '연꽃', 'options': ['꽃게', '바다', '물'], 'answer': '꽃게', 'hint': '연꽃 → 꽃___'},
    {'chain': '연기', 'options': ['기린', '하늘', '바람'], 'answer': '기린', 'hint': '연기 → 기___'},
    // ── 필 ──
    {'chain': '필통', 'options': ['통나무', '산', '구름'], 'answer': '통나무', 'hint': '필통 → 통___'},
    // ── 통 ──
    {'chain': '통나무', 'options': ['무지개', '바다', '강'], 'answer': '무지개', 'hint': '통나무 → 무___'},
    // ── 채 ──
    {'chain': '채소', 'options': ['소나무', '하늘', '물'], 'answer': '소나무', 'hint': '채소 → 소___'},
    // ── 소 ──
    {'chain': '소나무', 'options': ['무지개', '산', '바람'], 'answer': '무지개', 'hint': '소나무 → 무___'},
    {'chain': '소금', 'options': ['금붕어', '하늘', '구름'], 'answer': '금붕어', 'hint': '소금 → 금___'},
    {'chain': '소방차', 'options': ['차도', '바다', '강'], 'answer': '차도', 'hint': '소방차 → 차___'},
    // ── 금 ──
    {'chain': '금붕어', 'options': ['어머니', '산', '물'], 'answer': '어머니', 'hint': '금붕어 → 어___'},
    // ── 미 ──
    {'chain': '미역', 'options': ['역사', '하늘', '바람'], 'answer': '역사', 'hint': '미역 → 역___'},
    {'chain': '미술', 'options': ['술래', '바다', '구름'], 'answer': '술래', 'hint': '미술 → 술___'},
    // ── 역 ──
    {'chain': '역사', 'options': ['사자', '산', '강'], 'answer': '사자', 'hint': '역사 → 사___'},
    // ── 호 ──
    {'chain': '호랑이', 'options': ['이불', '하늘', '물'], 'answer': '이불', 'hint': '호랑이 → 이___'},
    {'chain': '호박', 'options': ['박쥐', '바다', '바람'], 'answer': '박쥐', 'hint': '호박 → 박___'},
    {'chain': '호수', 'options': ['수박', '산', '구름'], 'answer': '수박', 'hint': '호수 → 수___'},
    // ── 파 ──
    {'chain': '파도', 'options': ['도서관', '하늘', '강'], 'answer': '도서관', 'hint': '파도 → 도___'},
    {'chain': '파란색', 'options': ['색연필', '바다', '물'], 'answer': '색연필', 'hint': '파란색 → 색___'},
    {'chain': '파리', 'options': ['리본', '산', '바람'], 'answer': '리본', 'hint': '파리 → 리___'},
    // ── 색 ──
    {'chain': '색연필', 'options': ['필통', '하늘', '구름'], 'answer': '필통', 'hint': '색연필 → 필___'},
    // ── 형 ──
    {'chain': '형제', 'options': ['제비', '바다', '강'], 'answer': '제비', 'hint': '형제 → 제___'},
    // ── 제 ──
    {'chain': '제비', 'options': ['비누', '산', '물'], 'answer': '비누', 'hint': '제비 → 비___'},
    {'chain': '제주도', 'options': ['도서관', '하늘', '바람'], 'answer': '도서관', 'hint': '제주도 → 도___'},
    // ── 누 ──
    {'chain': '누나', 'options': ['나비', '바다', '구름'], 'answer': '나비', 'hint': '누나 → 나___'},
    // ── 화 ──
    {'chain': '화분', 'options': ['분필', '하늘', '강'], 'answer': '분필', 'hint': '화분 → 분___'},
    {'chain': '화살', 'options': ['살구', '산', '물'], 'answer': '살구', 'hint': '화살 → 살___'},
    // ── 분 ──
    {'chain': '분필', 'options': ['필통', '바다', '바람'], 'answer': '필통', 'hint': '분필 → 필___'},
    // ── 건 ──
    {'chain': '건포도', 'options': ['도마뱀', '하늘', '구름'], 'answer': '도마뱀', 'hint': '건포도 → 도___'},
    // ── 영 ──
    {'chain': '영어', 'options': ['어린이', '산', '강'], 'answer': '어린이', 'hint': '영어 → 어___'},
    // ── 위 ──
    {'chain': '위성', 'options': ['성게', '바다', '물'], 'answer': '성게', 'hint': '위성 → 성___'},
    // ── 성 ──
    {'chain': '성게', 'options': ['게장', '하늘', '바람'], 'answer': '게장', 'hint': '성게 → 게___'},
    // ── 게 ──
    {'chain': '게장', 'options': ['장갑', '산', '구름'], 'answer': '장갑', 'hint': '게장 → 장___'},
    // ── 장 ──
    {'chain': '장갑', 'options': ['갑옷', '바다', '강'], 'answer': '갑옷', 'hint': '장갑 → 갑___'},
    {'chain': '장미', 'options': ['미역', '하늘', '물'], 'answer': '미역', 'hint': '장미 → 미___'},
    // ── 일 ──
    {'chain': '일기', 'options': ['기차', '산', '바람'], 'answer': '기차', 'hint': '일기 → 기___'},
    // ── 관 ──
    {'chain': '관람', 'options': ['람보', '바다', '구름'], 'answer': '람보', 'hint': '관람 → 람___'},
  ];

  late List<Map<String, dynamic>> _rounds;
  int _step = 0, _correct = 0;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _initGame();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _initGame() {
    final shuffled = List.of(_allRounds)..shuffle();
    _rounds = shuffled.take(10).toList();
    setState(() {
      _step = 0;
      _correct = 0;
      _selected = null;
      _answered = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakQuestion);
  }

  void _speakQuestion() {
    final r = _rounds[_step];
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];
    _tts.speak(
        '"$chain"의 마지막 글자는 "$lastChar"입니다. 이 글자로 시작하는 단어를 고르세요!');
  }

  void _select(String opt) {
    if (_answered) return;
    final answer = _rounds[_step]['answer'] as String;
    setState(() {
      _selected = opt;
      _answered = true;
    });
    if (opt == answer) {
      _correct++;
      _tts.speak('${getRandomPraise()} $opt 맞아요!');
    } else {
      _tts.speak('아쉬워요. 정답은 $answer 예요.');
    }
  }

  void _next() {
    if (_step + 1 >= _rounds.length) {
      _showResult();
      return;
    }
    setState(() {
      _step++;
      _selected = null;
      _answered = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakQuestion);
  }

  void _showResult() {
    _tts.speak('끝말잇기를 모두 마쳤어요! $_correct개 맞혔어요! 어휘력이 정말 대단하세요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 끝말잇기 완료!',
            style: TextStyle(fontSize: 26),
            textAlign: TextAlign.center),
        content: Text(
          '${_rounds.length}문제 중 $_correct개 맞혔어요!\n어휘력이 대단해요! 🏆',
          style: const TextStyle(fontSize: 20, height: 1.6),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _initGame();
                  },
                  child: const Text('다시 하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[500],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _tts.stop();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('끝내기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final r = _rounds[_step];
    final answer = r['answer'] as String;
    final chain = r['chain'] as String;
    final lastChar = chain[chain.length - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('🔗 끝말잇기  ${_step + 1}/${_rounds.length}',
            style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.purple[500],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 진행 바 ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _rounds.length,
                      minHeight: 14,
                      color: Colors.purple,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_step + 1} / ${_rounds.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),

            // ── 현재 단어 카드 ──
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.purple[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      chain,
                      style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            '"$lastChar"(으)로 시작하는 단어는?',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: Colors.white, size: 24),
                            onPressed: _speakQuestion,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r['hint'],
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 보기 버튼 ──
            ...(r['options'] as List<String>).map((opt) {
              Color bgColor = Colors.white;
              Color borderColor = Colors.purple[200]!;
              Color textColor = Colors.black87;
              IconData? icon;

              if (_answered) {
                if (opt == answer) {
                  bgColor = Colors.green[50]!;
                  borderColor = Colors.green;
                  textColor = Colors.green[800]!;
                  icon = Icons.check_circle;
                } else if (opt == _selected) {
                  bgColor = Colors.red[50]!;
                  borderColor = Colors.red;
                  textColor = Colors.red[800]!;
                  icon = Icons.cancel;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => _select(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: borderColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 26),
                          const SizedBox(width: 12),
                        ] else ...[
                          const SizedBox(width: 38),
                        ],
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // ── 다음 문제 버튼 ──
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected == answer
                      ? Colors.green
                      : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: _next,
                child: Text(
                  _step + 1 >= _rounds.length
                      ? '결과 보기 🏆'
                      : _selected == answer
                          ? '다음 문제 👉'
                          : '다음 문제로 넘어가기 👉',
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}