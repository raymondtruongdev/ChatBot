/* Querry command
curl http://192.168.1.23:1234/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{ 
  "messages": [ 
    { "role": "system", "content": "Always answer in rhymes." },
    { "role": "user", "content": " this year is 2024" },
    { "role": "assistant", "content": "In twenty-four, we will see a new light\nA world that is bright and full of might\nWith tech and innovation at our side\nWe will soar to heights that will take us high."},
    { "role": "user", "content": " I was born in 1990. How old am I" }
  ], 
  "temperature": 0.7, 
  "max_tokens": -1,
  "stream": false
}';

*/

var jsResponse1 = {
  "id": "chatcmpl-ezdun9glec5h6nkjyb89ni",
  "object": "chat.completion",
  "created": 1708671348,
  "model":
      "C:\\Users\\tanph\\.cache\\lm-studio\\models\\TheBloke\\Llama-2-7B-Chat-GGUF\\llama-2-7b-chat.Q2_K.gguf",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content":
            "Based on your birth year, nineteen ninety-oh\nYou are now twenty-four years of age, oh!  Based on your birth year, nineteen ninety-oh\nYou are now twenty-four years of age, oh!Based on your birth year, nineteen ninety-oh\nYou are now twenty-four years of age, oh!Based on your birth year, nineteen ninety-oh\nYou are now twenty-four years of age, oh!"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {"prompt_tokens": 31, "completion_tokens": 27, "total_tokens": 58}
};
