# preprocessing
preprocessing, background remove for convolutional neural netwrok based verilog

Sample data를 JPG2HEX를 통해
8bit gray scale로 변환하여 HEX파일을 출력하였다.
JPG2HEX파일을 실행하면 8bit로 scaling된 결과를 확인할 수 있다.

또한, Partition을 위해 data, pyhon, testbench, verilog
를 모두 나누었다. Path에 대한 이해가 없다면 모든 Directory
안의 파일을 부모 폴더에 모두 복사하는 것을 권장한다.

또한, Image_read와 Image_write에서 INFILE과 OUTFILE 이름을
적절하게 변형하여 사용할 수 있다. 

Image_write 에서는 Bitmap 파일의 Header structure를
이해할 수 있도록 참고할 수 있는 사이트를 첨부하였다.
JP2HEX는 768x512로 Resizing하도록 설정되어 있으며,
Image_write.v에서 768x512 에 맞는 비트맵 파일을 출력하도록
HEADER파일이 만들어져 있다. 이 부분을 수정하여 원하는 사이즈의
이미지를 출력할 수 있다.

또한, Image_read 와 remover의 경우 하드웨어에 synthesis가
가능한 구조로 설계하였다. VGA를 출력하는 기본적인 예제를
공부한 후 모니터에 직접 출력하는 프로젝트를 할 수 있다.

순서
1. JPG2HEX를 이용하여 sample이 되는 사진 이름을 넣고, Resizing 사이즈를 선택, 출력할 파일 이름을 설정
2. Image_read의 INFILE을 1. 에서 출력한 파일 이름으로 설정
3. Image_write의 OUTPUT FILE을 비트맵 파일 이름으로 설정, 1. 에서 선택한 사이즈에 맞도록 비트맵 헤더 변경
4. tb_top.v 를 디버깅 하여 비트맵 파일 출력

** verilog는 C, python, Matlab 과 같이 이미지 파일을 빠르게 출력할 수 있도록 설계되어 있지 않습니다. 하드웨어에서 Implementation 할 경우
보드를 동작시키자마자 모니터에서 출력되는 결과를 확인할 수 있지만, 현재의 코드는 비트맵 파일을 출력하는데 대략 3~4분 가량이 소모됩니다.
외부 GPU가 없는 경우이며, GPU가 있는 경우 작업 속도는 더 빠릅니다. 출력 속도를 높이고 싶다면, ROM에 저장한 데이터를 temp buffer 여러개를
만들어 나누어 갖도록 하여, 동시에 여러 픽셀을 병렬처리 하도록 하십시오. Image_write에서 비트맵 파일을 출력하기 위해 설계한 for loop에서 
hint를 얻을 수 있습니다.
