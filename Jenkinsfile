pipeline {
  agent { label 'master' }

  parameters {
    booleanParam(name : 'BUILD_DOCKER_IMAGE', defaultValue : true, description : 'BUILD_DOCKER_IMAGE')
    booleanParam(name : 'RUN_TEST', defaultValue : true, description : 'RUN_TEST')
    booleanParam(name : 'PUSH_DOCKER_IMAGE', defaultValue : true, description : 'PUSH_DOCKER_IMAGE')
    booleanParam(name : 'DEPLOY_WORKLOAD', defaultValue : true, description : 'DEPLOY_WORKLOAD')

    //CI
    string(name : 'AWS_ACCOUNT_ID', defaultValue : '917466992560', description : 'AWS_ACCOUNT_ID')
    string(name : 'DOCKER_IMAGE_NAME', defaultValue : 'test', description : 'DOCKER_IMAGE_NAME')
    string(name : 'DOCKER_TAG', defaultValue : '1', description : 'DOCKER_TAG')
    //CD
    string(name : 'TARGET_SVR_USER', defaultValue : 'ec2-user', description : 'TARGET_SVR_USER')
    string(name : 'TARGET_SVR', defaultValue : '13.125.244.38', description : 'TARGET_SVR')


  }

  environment {
    REGION = "ap-northeast-2"
    ECR_REPOSITORY = "${params.AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com"
    DOCKER_IMAGE = "${ECR_REPOSITORY}/${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}"
    CONTAINER_NAME = "web-demo"

    CODEBUILD_NAME = "jenkins-codebuild-"
    CODEBUILD_ARTIFACT_S3_NAME = "jenkins-s3-codebuild-yj"
    CODEBUILD_ARTIFACT_S3_KEY = "${currentBuild.number}/${CODEBUILD_NAME}"
    CODEDEPLOY_NAME = "jenkins-slave-codedeploy-test"
    CODEDEPLOY_GROUP_NAME = "jenkins-slave-codedeploy-group"

  }

  stages {
    stage('============ AWS CodeBuild Docker Image ============') {
      when { expression { return params.BUILD_DOCKER_IMAGE } }
        agent { label 'master' }
        steps {
            awsCodeBuild(
              credentialsType: 'keys',
              region: "${REGION}",
              projectName: "${CODEBUILD_NAME}",
              sourceControlType: 'jenkins',
              sseAlgorithm: 'AES256',
              buildSpecFile: "buildspec.yml"
            )
        }
    }

    // stage('============ Deploy workload ============') {
    //     when { expression { return params.DEPLOY_WORKLOAD } }
    //    // agent { label 'deploy' }
    //     steps {
    //         sshagent (credentials: ['aws-ec2-user-ssh']) {
    //             sh """#!/bin/bash
    //                 ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    //                     ${params.TARGET_SVR_USER}@${params.TARGET_SVR} \
    //                     'aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}; \
    //                      docker rm -f ${CONTAINER_NAME};
    //                      docker run -d -p 80:80 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}';
    //             """
    //         }
    //     }
    // }


    
    // stage('Prompt for deploy') {
    //     steps {
    //       // input 'Deploy this ??'
    //       script {
    //         env.APPROAL_NUM = input message: 'Please enter the approval number',
    //                          parameters: [string(defaultValue: '',
    //                                       description: '',
    //                                       name: 'APPROVAL_NUM')]
    //         }

    //         echo "${env.APPROAL_NUM}"
    //     }
    // }
    // stage('============ Deploy workload ============') {
    //     when { expression { return params.DEPLOY_WORKLOAD } }
    //     agent { label 'master' }
    //     steps {
    //         echo "Run CodeDeploy with creating deployment!"
    //         script {
    //             sh'''
    //                 aws deploy create-deployment \
    //                     --application-name ${CODEDEPLOY_NAME} \
    //                     --deployment-group-name ${CODEDEPLOY_GROUP_NAME} \
    //                     --region ${REGION} \
    //                     --s3-location bucket=${CODEBUILD_ARTIFACT_S3_NAME},bundleType=zip,key=${CODEBUILD_ARTIFACT_S3_KEY} \
    //                     --file-exists-behavior OVERWRITE \
    //                     --output json > DEPLOYMENT_ID.json
    //             '''
    //             def DEPLOYMENT_ID = sh(script: "cat DEPLOYMENT_ID.json | grep -o '\"deploymentId\": \"[^\"]*' | cut -d'\"' -f4", returnStdout: true).trim()
    //             echo "$DEPLOYMENT_ID"
    //             sh "rm -rf ./DEPLOYMENT_ID.json"
    //             def DEPLOYMENT_RESULT = ""
    //             while("$DEPLOYMENT_RESULT" != "\"Succeeded\"") {
    //                 DEPLOYMENT_RESULT = sh(
    //                     script:"aws deploy get-deployment \
    //                                 --region ${REGION} \
    //                                 --query \"deploymentInfo.status\" \
    //                                 --deployment-id ${DEPLOYMENT_ID}",
    //                     returnStdout: true
    //                 ).trim()
    //                 echo "$DEPLOYMENT_RESULT"
    //                 if ("$DEPLOYMENT_RESULT" == "\"Failed\"") {
    //                     currentBuild.result = 'FAILURE'
    //                     break
    //                 }
    //                 sleep(10) // sleep 10s
    //             }
    //             currentBuild.result = 'SUCCESS'
    //         }
    //     }
    // }

  }
  // post {
  //   cleanup {
  //       echo "Post cleanup"
  //   }
  // }
}