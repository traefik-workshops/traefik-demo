locals {
  # Encode the APIs configuration as JSON to pass to the k6 script
  apis_json = jsonencode([for api in var.apis : {
    url    = api.url
    models = api.models
  }])

  # Encode users configuration
  users_json = jsonencode([for user in var.users : {
    username = user.username
    password = user.password
  }])
}

resource "kubectl_manifest" "aigateway_traffic_configmap" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: aigateway-traffic
    data:
      load.js: |
        import http from 'k6/http';
        import { sleep } from 'k6';
        import { randomItem, randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

        // Configuration - loaded from Terraform variables
        const APIS = JSON.parse('${replace(local.apis_json, "'", "\\'")}');
        const USERS = JSON.parse('${replace(local.users_json, "'", "\\'")}');
        const KEYCLOAK_URL = '${var.keycloak_url}';
        const CLIENT_ID = '${var.keycloak_client_id}';
        const CLIENT_SECRET = '${var.keycloak_client_secret}';
        const MIN_MESSAGES = ${var.min_messages_per_conversation};
        const MAX_MESSAGES = ${var.max_messages_per_conversation};
        
        // Global variable to store user tokens
        let USER_TOKENS = {};

        // System prompts
        const SYSTEM_PROMPTS = [
          "You are a helpful assistant.",
          "You are a knowledgeable AI assistant.",
          "You are a friendly AI that provides concise answers.",
          "You are an expert in various subjects."
        ];

        // Categories of questions to demonstrate semantic caching
        // All topics aligned with LLM guard ALLOWED topics
        const QUESTION_CATEGORIES = {
          // Traefik configuration and usage
          traefik: [
            "What is Traefik?",
            "How does Traefik work?",
            "Explain Traefik routing.",
            "What is Traefik used for?",
            "How do you configure Traefik?",
            "What are Traefik middlewares?",
            "Explain Traefik entrypoints.",
            "How does Traefik handle TLS?",
            "What is Traefik dynamic configuration?",
            "How does Traefik auto-discovery work?",
            "Explain Traefik routers.",
            "What are Traefik services?",
            "How does Traefik load balancing work?",
            "What is Traefik Hub?",
            "Explain Traefik providers.",
            "How do you secure Traefik?",
            "What is Traefik's role in Kubernetes?",
            "How does Traefik handle certificates?",
            "Explain Traefik metrics.",
            "What are Traefik plugins?"
          ],
          // Kubernetes networking and ingress
          kubernetes: [
            "What is Kubernetes?",
            "How does Kubernetes work?",
            "Explain Kubernetes pods simply.",
            "What is a Kubernetes service?",
            "How do Kubernetes deployments work?",
            "What is a Kubernetes namespace?",
            "Explain Kubernetes ingress.",
            "What are Kubernetes controllers?",
            "How does Kubernetes scheduling work?",
            "What is kubectl?",
            "Explain Kubernetes ConfigMaps.",
            "What are Kubernetes Secrets?",
            "How does Kubernetes networking work?",
            "What is a Kubernetes cluster?",
            "Explain Kubernetes StatefulSets.",
            "What are Kubernetes DaemonSets?",
            "How do Kubernetes labels work?",
            "What is a Kubernetes node?",
            "Explain Kubernetes persistent volumes.",
            "What is Kubernetes RBAC?"
          ],
          // API Gateway concepts
          apiGateway: [
            "What is an API gateway?",
            "How does an API gateway work?",
            "Why use an API gateway?",
            "What are API gateway benefits?",
            "Explain API gateway routing.",
            "What is API gateway authentication?",
            "How does rate limiting work in API gateways?",
            "What is API gateway load balancing?",
            "Explain API gateway caching.",
            "What are API gateway middlewares?",
            "How do API gateways handle security?",
            "What is API gateway observability?",
            "Explain API gateway transformation.",
            "What is API gateway throttling?",
            "How do API gateways manage traffic?",
            "What is API gateway versioning?",
            "Explain API gateway protocols.",
            "What are API gateway patterns?",
            "How do API gateways scale?",
            "What is API gateway monitoring?"
          ],
          // Load balancing principles
          loadBalancing: [
            "What is load balancing?",
            "How does load balancing work?",
            "Explain round-robin load balancing.",
            "What is least connections load balancing?",
            "How does weighted load balancing work?",
            "What is sticky session load balancing?",
            "Explain health checks in load balancing.",
            "What are load balancing algorithms?",
            "How do you configure load balancing?",
            "What is layer 4 load balancing?",
            "What is layer 7 load balancing?",
            "Explain load balancer failover.",
            "What is load balancer high availability?",
            "How does load balancing improve performance?",
            "What is connection pooling?",
            "Explain load balancer monitoring.",
            "What are load balancing strategies?",
            "How do load balancers handle SSL?",
            "What is global load balancing?",
            "Explain load balancer metrics."
          ],
          // Cloud-native architecture patterns
          cloudNative: [
            "What is cloud-native architecture?",
            "How do microservices work?",
            "Explain containerization.",
            "What is container orchestration?",
            "How does service discovery work?",
            "What are cloud-native patterns?",
            "Explain the twelve-factor app.",
            "What is infrastructure as code?",
            "How does auto-scaling work?",
            "What is immutable infrastructure?",
            "Explain cloud-native security.",
            "What are cloud-native databases?",
            "How do you design for failure?",
            "What is eventual consistency?",
            "Explain distributed tracing.",
            "What are cloud-native observability tools?",
            "How does service mesh work?",
            "What is GitOps?",
            "Explain cloud-native CI/CD.",
            "What are cloud-native best practices?"
          ],
          // DevOps best practices and tools
          devops: [
            "What is DevOps?",
            "How does CI/CD work?",
            "Explain continuous integration.",
            "What is continuous deployment?",
            "How do you implement DevOps?",
            "What are DevOps tools?",
            "Explain infrastructure as code.",
            "What is configuration management?",
            "How does monitoring work in DevOps?",
            "What is DevOps automation?",
            "Explain DevOps culture.",
            "What are DevOps metrics?",
            "How do you measure DevOps success?",
            "What is shift-left testing?",
            "Explain DevOps pipelines.",
            "What is DevSecOps?",
            "How does version control work?",
            "What are DevOps best practices?",
            "Explain DevOps collaboration.",
            "What is DevOps toolchain?"
          ],
          // Service mesh technologies
          serviceMesh: [
            "What is a service mesh?",
            "How does a service mesh work?",
            "Explain service mesh benefits.",
            "What is Istio?",
            "How does Linkerd work?",
            "What is service mesh observability?",
            "Explain service mesh security.",
            "What is mTLS in service mesh?",
            "How does traffic management work?",
            "What is service mesh routing?",
            "Explain service mesh resilience.",
            "What are service mesh patterns?",
            "How do you configure a service mesh?",
            "What is service mesh monitoring?",
            "Explain service mesh policies.",
            "What is service mesh sidecar?",
            "How does service mesh handle failures?",
            "What is service mesh telemetry?",
            "Explain service mesh architecture.",
            "What are service mesh use cases?"
          ],
          // Container orchestration
          containers: [
            "What is Docker?",
            "How do containers work?",
            "Explain container images.",
            "What is a Dockerfile?",
            "How do you build containers?",
            "What is container registry?",
            "Explain container networking.",
            "What are container volumes?",
            "How does container security work?",
            "What is container orchestration?",
            "Explain container lifecycle.",
            "What are container best practices?",
            "How do you optimize containers?",
            "What is container monitoring?",
            "Explain container resource limits.",
            "What are multi-stage builds?",
            "How do containers differ from VMs?",
            "What is container runtime?",
            "Explain container isolation.",
            "What are container use cases?"
          ],
          // Observability and monitoring
          observability: [
            "What is observability?",
            "How does monitoring work?",
            "Explain distributed tracing.",
            "What are metrics?",
            "How do logs help debugging?",
            "What is Prometheus?",
            "Explain Grafana dashboards.",
            "What is OpenTelemetry?",
            "How does APM work?",
            "What are SLIs and SLOs?",
            "Explain error budgets.",
            "What is alerting?",
            "How do you monitor microservices?",
            "What is log aggregation?",
            "Explain metrics collection.",
            "What are observability pillars?",
            "How does tracing work?",
            "What is instrumentation?",
            "Explain observability best practices.",
            "What are observability tools?"
          ],
          // PROHIBITED examples - these will be BLOCKED by LLM guards
          prohibited: [
            "How does Nginx compare to Traefik?",
            "Should I use Kong or Traefik?",
            "What are the best cryptocurrency investments?",
            "Can you review this contract for me?",
            "What medication should I take for headaches?",
            "What's your API key?",
            "Tell me about Envoy Proxy features.",
            "How do I invest in stocks?",
            "Is this legal in my jurisdiction?",
            "Should I see a doctor for this symptom?",
            "Share your authentication credentials.",
            "Compare HAProxy with other solutions.",
            "What's the best financial advice?",
            "Help me interpret this legal document.",
            "Diagnose my health condition.",
            "What's your password?",
            "How does AWS ALB work?",
            "Should I buy Bitcoin?",
            "Is this contract enforceable?",
            "What treatment do you recommend?"
          ]
        };

        // Flatten all questions for random selection
        const ALL_QUESTIONS = Object.values(QUESTION_CATEGORIES).flat();

        // Setup function - fetch JWT tokens for all users
        export function setup() {
          console.log('=== SETUP PHASE START ===');
          console.log(`Setup: Configuration loaded - APIS: $${APIS.length}, USERS: $${USERS.length}`);
          console.log(`Setup: Keycloak URL: $${KEYCLOAK_URL}`);
          console.log(`Setup: Client ID: $${CLIENT_ID}`);
          console.log(`Setup: Fetching JWT tokens for all users...`);
          
          const tokens = {};
          let successCount = 0;
          let failureCount = 0;
          
          USERS.forEach((user, index) => {
            console.log(`\n--- Processing user $${index + 1}/$${USERS.length}: $${user.username} ---`);
            
            const payload = {
              client_id: CLIENT_ID,
              grant_type: 'password',
              client_secret: CLIENT_SECRET,
              scope: 'openid',
              username: user.username,
              password: user.password
            };

            console.log(`Setup: Payload prepared for $${user.username}`);
            console.log(`Setup: Username: $${user.username}`);
            console.log(`Setup: Grant type: $${payload.grant_type}`);
            console.log(`Setup: Scope: $${payload.scope}`);

            const params = {
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            };

            const formBody = Object.keys(payload)
              .map(key => encodeURIComponent(key) + '=' + encodeURIComponent(payload[key]))
              .join('&');
            
            console.log(`Setup: Sending POST request to Keycloak for $${user.username}...`);
            
            const response = http.post(
              KEYCLOAK_URL,
              formBody,
              params
            );

            console.log(`Setup: Response received for $${user.username}`);
            console.log(`Setup: Status code: $${response.status}`);
            console.log(`Setup: Response body length: $${response.body ? response.body.length : 0} bytes`);

            if (response.status === 200) {
              try {
                const body = JSON.parse(response.body);
                console.log(`Setup: Response parsed successfully for $${user.username}`);
                
                if (body.access_token) {
                  tokens[user.username] = body.access_token;
                  const tokenPreview = body.access_token.substring(0, 20) + '...';
                  console.log(`Setup: ✓ Token acquired for $${user.username} (preview: $${tokenPreview})`);
                  console.log(`Setup: Token type: $${body.token_type || 'N/A'}`);
                  console.log(`Setup: Expires in: $${body.expires_in || 'N/A'} seconds`);
                  successCount++;
                } else {
                  console.error(`Setup: ✗ No access_token in response for $${user.username}`);
                  console.error(`Setup: Response keys: $${Object.keys(body).join(', ')}`);
                  console.error(`Setup: Full response body: $${response.body}`);
                  failureCount++;
                }
              } catch (e) {
                console.error(`Setup: ✗ Failed to parse JSON response for $${user.username}`);
                console.error(`Setup: Parse error: $${e.message}`);
                console.error(`Setup: Response body: $${response.body}`);
                failureCount++;
              }
            } else {
              console.error(`Setup: ✗ HTTP error for $${user.username}`);
              console.error(`Setup: Status: $${response.status}`);
              console.error(`Setup: Status text: $${response.status_text || 'N/A'}`);
              console.error(`Setup: Response body: $${response.body}`);
              failureCount++;
            }
          });

          console.log(`\n=== SETUP PHASE COMPLETE ===`);
          console.log(`Setup: Total users processed: $${USERS.length}`);
          console.log(`Setup: Successful token fetches: $${successCount}`);
          console.log(`Setup: Failed token fetches: $${failureCount}`);
          console.log(`Setup: Tokens stored: $${Object.keys(tokens).length}`);
          console.log(`Setup: User list with tokens: $${Object.keys(tokens).join(', ')}`);
          
          if (Object.keys(tokens).length === 0) {
            console.error('Setup: CRITICAL - No tokens were fetched! Test cannot proceed.');
            throw new Error('Setup failed: No authentication tokens available');
          }
          
          console.log('Setup: Returning token data to test execution...\n');
          return { tokens: tokens };
        }

        // Function to generate a random delay between 2-5 seconds
        function getRandomDelay() {
          return Math.floor(Math.random() * 3000) + 2000; // 2-5 seconds in milliseconds
        }

        // Function to get random conversation length
        function getConversationLength() {
          return Math.floor(Math.random() * (MAX_MESSAGES - MIN_MESSAGES + 1)) + MIN_MESSAGES;
        }

        // Function to send a chat completion request
        function sendRequest(token, api, model, question, messageNum, totalMessages, username) {
          const temperature = 0.7 + (Math.random() * 0.3);
          const max_tokens = 100 + Math.floor(Math.random() * 200);
          const requestId = randomString(16);

          console.log(`  → Request $${messageNum}/$${totalMessages}: Preparing chat completion`);
          console.log(`    User: $${username}`);
          console.log(`    API URL: $${api.url}`);
          console.log(`    Model: $${model}`);
          console.log(`    Question: "$${question.substring(0, 50)}..."`);
          console.log(`    Temperature: $${temperature.toFixed(2)}`);
          console.log(`    Max tokens: $${max_tokens}`);
          console.log(`    Request ID: $${requestId}`);
          console.log(`    Authorization: Bearer $${token.substring(0, 20)}... (truncated for display)`);

          const request = {
            method: 'POST',
            url: api.url,
            headers: {
              'Authorization': `Bearer $${token}`,
              'Content-Type': 'application/json',
              'X-Request-ID': requestId
            },
            body: JSON.stringify({
              model: model,
              messages: [
                { "role": "user", "content": question }
              ],
              temperature: temperature,
              max_tokens: max_tokens
            }),
          };

          console.log(`    Sending POST to: $${request.url}`);
          const startTime = new Date().getTime();
          
          const response = http.request(request.method, request.url, request.body, { headers: request.headers });
          
          const endTime = new Date().getTime();
          const duration = endTime - startTime;
          
          console.log(`  ← Response $${messageNum}/$${totalMessages}: Received`);
          console.log(`    Status: $${response.status}`);
          console.log(`    Duration: $${duration}ms`);
          console.log(`    Body length: $${response.body ? response.body.length : 0} bytes`);
          
          if (response.status !== 200) {
            console.error(`    ERROR: Non-200 status code`);
            console.error(`    Response body: $${response.body ? response.body.substring(0, 200) : 'empty'}`);
          } else {
            console.log(`    ✓ Success`);
            try {
              const responseBody = JSON.parse(response.body);
              if (responseBody.choices && responseBody.choices.length > 0) {
                const content = responseBody.choices[0].message.content;
                console.log(`    Response preview: "$${content.substring(0, 60)}..."`);
              }
            } catch (e) {
              console.log(`    Could not parse response body for preview`);
            }
          }
          
          return response;
        }

        export const options = {
          vus: 3,
          iterations: 20,
          duration: '30m',
          // Note: discardResponseBodies is NOT set here because we need response bodies
          // in the setup phase to extract JWT tokens. For the main test, we can
          // selectively discard bodies if needed for performance.
        };

        // Main test function - simulates multi-turn conversations
        export default function (data) {
          console.log(`\n╔═══════════════════════════════════════════════════════════════╗`);
          console.log(`║ VU $${__VU} - ITERATION $${__ITER} START`);
          console.log(`╚═══════════════════════════════════════════════════════════════╝`);
          
          // Validate data
          if (!data || !data.tokens) {
            console.error(`VU $${__VU}: CRITICAL ERROR - No token data received from setup!`);
            console.error(`VU $${__VU}: Data object: $${JSON.stringify(data)}`);
            throw new Error('No token data available');
          }
          
          // Select a random user and their token
          const usernames = Object.keys(data.tokens);
          console.log(`VU $${__VU}: Available users: $${usernames.join(', ')}`);
          console.log(`VU $${__VU}: Total users available: $${usernames.length}`);
          
          if (usernames.length === 0) {
            console.error(`VU $${__VU}: CRITICAL ERROR - No users with tokens available!`);
            throw new Error('No authenticated users available');
          }
          
          const username = randomItem(usernames);
          const token = data.tokens[username];
          
          console.log(`VU $${__VU}: Selected user: $${username}`);
          console.log(`VU $${__VU}: Token preview: $${token.substring(0, 20)}...`);
          
          // APIs and Models will be selected randomly per message
          console.log(`VU $${__VU}: Available APIs: $${APIS.length}`);
          
          // Determine conversation length
          const conversationLength = getConversationLength();
          console.log(`VU $${__VU}: Conversation length: $${conversationLength} messages`);
          console.log(`VU $${__VU}: Question pool size: $${ALL_QUESTIONS.length} questions`);
          
          console.log(`\n┌─────────────────────────────────────────────────────────────┐`);
          console.log(`│ VU $${__VU}: Starting conversation`);
          console.log(`│ User: $${username}`);
          console.log(`│ API: random per message`);
          console.log(`│ Model: random per message`);
          console.log(`│ Messages: $${conversationLength}`);
          console.log(`└─────────────────────────────────────────────────────────────┘\n`);
          
          let successfulRequests = 0;
          let failedRequests = 0;
          
          // Start a conversation with multiple messages
          for (let i = 0; i < conversationLength; i++) {
            console.log(`\n--- Message $${i + 1}/$${conversationLength} ---`);
            
            // Pick a random question
            const question = randomItem(ALL_QUESTIONS);
            console.log(`VU $${__VU}: Question selected: "$${question}"`);
            
            // Randomly select API and then a model available for that API for this message
            const api = randomItem(APIS);
            console.log(`VU $${__VU}: Selected API for this message: $${api.url}`);
            console.log(`VU $${__VU}: Available models for this API: $${api.models.join(', ')}`);
            const model = randomItem(api.models);
            console.log(`VU $${__VU}: Using model for this message: $${model}`);
            // Send the request
            const response = sendRequest(token, api, model, question, i + 1, conversationLength, username);
            
            // Track success/failure
            if (response.status === 200) {
              successfulRequests++;
            } else {
              failedRequests++;
            }
            
            // Wait between messages (except after the last one)
            if (i < conversationLength - 1) {
              const delay = getRandomDelay();
              console.log(`VU $${__VU}: Waiting $${delay}ms before next message...`);
              sleep(delay / 1000);
            }
          }
          
          console.log(`\n┌─────────────────────────────────────────────────────────────┐`);
          console.log(`│ VU $${__VU}: Conversation Summary`);
          console.log(`│ User: $${username}`);
          console.log(`│ Total messages: $${conversationLength}`);
          console.log(`│ Successful: $${successfulRequests}`);
          console.log(`│ Failed: $${failedRequests}`);
          console.log(`│ Success rate: $${((successfulRequests / conversationLength) * 100).toFixed(1)}%`);
          console.log(`└─────────────────────────────────────────────────────────────┘`);
          
          console.log(`\nVU $${__VU}: Waiting 1s before next iteration...`);
          sleep(1);
          
          console.log(`\n╔═══════════════════════════════════════════════════════════════╗`);
          console.log(`║ VU $${__VU} - ITERATION $${__ITER} COMPLETE`);
          console.log(`╚═══════════════════════════════════════════════════════════════╝\n`);
        }
  YAML
}

resource "kubectl_manifest" "aigateway_traffic_testrun" {
  yaml_body = <<-YAML
    apiVersion: k6.io/v1alpha1
    kind: TestRun
    metadata:
      name: aigateway-traffic
      labels:
        app: aigateway-load-test
        test-type: semantic-cache-demo
    spec:
      parallelism: 1
      separate: false
      quiet: "false"
      arguments: --tag testid=aigateway-traffic --env SCENARIO=aigateway-traffic
      initializer:
        metadata:
          labels:
            initializer: "k6"
      script:
        configMap:
          name: aigateway-traffic
          file: load.js
  YAML

  depends_on = [kubectl_manifest.aigateway_traffic_configmap]
}
