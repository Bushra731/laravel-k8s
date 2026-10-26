pipeline {
  agent any
  environment {
    IMAGE = "bushra731/laravel-app"
    TAG   = "${BUILD_NUMBER}"
    PATH  = "/snap/bin:/usr/local/bin:/usr/bin:/bin"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Image') {
      steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh '''
            echo $P | docker login -u $U --password-stdin
            docker push $IMAGE:$TAG
            docker push $IMAGE:latest
          '''
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
            sed -i "s|IMAGE_PLACEHOLDER|$IMAGE:$TAG|g" k8s/laravel.yaml
            kubectl apply -f k8s/namespace.yaml
            kubectl apply -f k8s/secret.yaml
            kubectl apply -f k8s/mysql.yaml
            kubectl apply -f k8s/laravel.yaml
            kubectl -n laravel rollout status deployment/mysql --timeout=300s
            kubectl -n laravel rollout status deployment/laravel-app --timeout=300s
          '''
        }
      }
    }
    stage('Verify') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
            kubectl -n laravel get pods,svc
            sleep 5
            curl -s http://192.168.49.2:30080/dbcheck || true
          '''
        }
      }
    }
  }
}
