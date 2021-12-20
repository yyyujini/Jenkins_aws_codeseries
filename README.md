# Getting Started AWS Code Series #1
```
- AWS Code Build를 활용한 Continuous Integration 구축
```
![image](https://user-images.githubusercontent.com/75412225/146699115-a140f035-2ee9-477f-a05f-1c838c811988.png)


### 사전준비
```
➔	Getting Started Jenkins CI/CD #1,2의 모든 작업
➔	Jenkins EC2의 S3, CodeBuild IAM 권한 필요
```

#### Jenkins Plugin 설치
![image](https://user-images.githubusercontent.com/75412225/146699153-40f49eaf-5e92-48a6-b1b2-8d241a9a013e.png)
#### AWS Codebuild 생성
```
소스 설정
소스 공급자 : S3
버킷 : jenkins-s3-codebuild-yj
S3 폴더 : project
```
##### 환경설정
![image](https://user-images.githubusercontent.com/75412225/146699608-e67236dd-5b19-40cd-8737-7018c02f8605.png)
##### 역할 권한 설정 (※ 실제 구축시 디테일한 권한 설정 및 추가 구성에서 네트워크 설정 필수)
![image](https://user-images.githubusercontent.com/75412225/146699288-ec36a072-b370-45c9-8d3a-3c93cb5e027a.png)
##### BuildSpec 설정
![image](https://user-images.githubusercontent.com/75412225/146699303-a0a24de0-4f90-4a19-bd8b-868f43f30ca2.png)
##### Artifacts 설정
![image](https://user-images.githubusercontent.com/75412225/146699668-f5686d74-5225-4204-981d-5ac185624a12.png)
##### Jenkinsfile 수정
```
CODEBUILD_NAME 환경변수 추가
Build Docker Image Stage 코드 수정
```
##### buildspec.yml 파일 추가
``` C
phases:
  pre_build: // 첫번째로 실행 되는 빌드 커멘드 (ECR Login)
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
  
  build: // Build 커멘드 (Docker Image 빌드)
    on-failure: ABORT
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t ${ECR_URL}/${ECR_DOCKER_IMAGE}:${ECR_DOCKER_TAG} .
  post_build: // 마지막 Build 커멘드 (ECR Image PUSH)
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push ${ECR_URL}/${ECR_DOCKER_IMAGE}:${ECR_DOCKER_TAG}
```
#### 검증
![image](https://user-images.githubusercontent.com/75412225/146699796-a27d0efd-fd8a-4944-a935-0fd9cd8b506c.png)
##### jenkins Console output
![image](https://user-images.githubusercontent.com/75412225/146699827-6bd0ce8e-49b6-4af6-97c8-a24dc8b55293.png)
##### Codebuild Log
![image](https://user-images.githubusercontent.com/75412225/146699842-640cbb9a-e79a-4fa6-a3df-bc8b0b7308c7.png)
##### ECR 이미지 확인
![image](https://user-images.githubusercontent.com/75412225/146699860-c8268361-2bad-41b0-8122-cc5dacd01494.png)


# Getting Started AWS Code Series #2
```
- AWS Code Deploy를 활용한 Continuous Deploy 구축
```
![image](https://user-images.githubusercontent.com/75412225/146700183-a28248d8-b985-4138-93e3-afd6b6862533.png)


### 사전준비
```
➔	Getting Started Jenkins CI/CD #1,2의 모든 작업
➔	Jenkins EC2에 S3, CodeBuild, Codedeploy IAM 권한 필요
➔	Target 서버에 	- CodeDeploy Agent 설치, S3 권한 (CodeDeploy가 저장한 데이터 Download)
```

#### Codedeploy Application 생성
![image](https://user-images.githubusercontent.com/75412225/146700205-19e2c75d-f9b7-42c0-af5a-ad6c3f9977a2.png)
![image](https://user-images.githubusercontent.com/75412225/146700220-547368eb-7ec8-4977-9bc9-c8ca3eaae56a.png)

#### 배포 그룹 생성
![image](https://user-images.githubusercontent.com/75412225/146700253-0ad9f807-b904-4093-a9cd-19b9af13491b.png)

#### 환경 구성
![image](https://user-images.githubusercontent.com/75412225/146700272-9a941ac4-68b2-40d3-a0ee-dc0eca4e92a4.png)

#### Agent 설치를 위한 Target EC2 Userdata
``` c
#!/bin/bash

sudo yum update
sudo yum install -y docker git java-1.8.0-openjdk ruby wget

cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent status
rm -rf ./install

cat >/etc/init.d/codedeploy-start.sh <<EOL
#!/bin/bash
sudo service codedeploy-agent restart
EOL
chmod +x /etc/init.d/codedeploy-start.sh

sudo usermod -aG docker ec2-user
sudo systemctl enable docker
sudo systemctl start docker
```
#### Jenkinsfile 수정
```
artifact 설정으로 산출물 데이터 S3에 ZIP로 저장(나중에 Target 서버에서 Get)
```
![image](https://user-images.githubusercontent.com/75412225/146700338-10f00f65-9692-42e9-abf8-d7604dfc778b.png)

#### CodeDeploy를 위한 추가 스크립트 작성
![image](https://user-images.githubusercontent.com/75412225/146700365-8426f28b-4b19-4db0-8d59-3ca787554dc5.png)

#### buildspec.yml 수정
```
artifacts 설정으로 S3에 업로드 할 파일 정의
```

### 검증
#### Jenkins Console Output
![image](https://user-images.githubusercontent.com/75412225/146700792-1666b813-8353-4134-9db7-548fb5031c3c.png)
#### Codeploy 배포 Status
![image](https://user-images.githubusercontent.com/75412225/146700807-4c319bb1-ead2-4c70-ade7-b7c06183829f.png)

# Getting Started AWS Code Series #3
```
- AWS CodePipeline을 활용한 CI/CD 구축
```
![image](https://user-images.githubusercontent.com/75412225/146700939-06d55dbe-b457-4a18-8a22-6f61fb6e8b2f.png)


### 사전준비
```
➔	CodeBuild 생성 (aws-pipeline-codebuild-yj)
➔	CodeBuild Source S3 생성 (codepipeline-s3-codebuild-yj)
➔	CodeBuild Artifact S3 생성: (codepipeline-s3-codebuild-artifact-yj)
➔	CodeDeploy 생성 (codepipeline-codedeploy)
➔	CodeDeploy 배포 그룹 생성 (codepipeline-codedeploy-group)
➔	Target 서버 생성 (CodeDeploy Agent 설치)
➔	활용 되는 서비스 IAM 설정(Getting Started AWS Code Series 1,2편 참고)
```

#### CodePipeline 생성
![image](https://user-images.githubusercontent.com/75412225/146700975-32e354c4-aa00-4c45-ac8d-48461285b3bd.png)
#### 소스 스테이지 설정
![image](https://user-images.githubusercontent.com/75412225/146700986-5bea130f-7df0-424b-943f-e080a29e5dab.png)
#### Github 연결
![image](https://user-images.githubusercontent.com/75412225/146701003-9f5fd73c-0d50-4325-889d-413c0ed9e6f6.png)
#
![image](https://user-images.githubusercontent.com/75412225/146701013-4e126593-de7e-4df1-893b-b92c78419e87.png)
#### 빌드 스테이지 설정 / 배포 스테이지 설정
##### 생성한 CodeDeploy 바인딩
![image](https://user-images.githubusercontent.com/75412225/146701061-18873ee8-7518-4b00-bcc0-6bd9fe8887fb.png)

#### 검증
##### CodePipeline Status
![image](https://user-images.githubusercontent.com/75412225/146701100-5697f05e-e20c-49c9-a09b-c41215791bce.png)
##### CodeBuild Status
![image](https://user-images.githubusercontent.com/75412225/146701117-66ee94ab-515c-4d9a-bbf9-8b5d1022bc2b.png)
##### CodeDeploy Status
![image](https://user-images.githubusercontent.com/75412225/146701154-1be3a0f8-0f5f-46b6-a054-10c9c3784384.png)

