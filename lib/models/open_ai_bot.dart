class OpenAiData {
  String? id;
  String? object;
  int? created;
  String? model;
  List<Choice>? choices;
  Usage? usage;

  OpenAiData({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
  });

  factory OpenAiData.fromJson(Map<String, dynamic> json) => OpenAiData(
        id: json['id'] as String?,
        object: json['object'] as String?,
        created: json['created'] as int?,
        model: json['model'] as String?,
        choices: (json['choices'] as List<dynamic>?)
            ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
            .toList(),
        usage: json['usage'] == null
            ? null
            : Usage.fromJson(json['usage'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'created': created,
        'model': model,
        'choices': choices?.map((e) => e.toJson()).toList(),
        'usage': usage?.toJson(),
      };
}

class Message {
  String? role;
  String? content;

  Message({this.role, this.content});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: json['role'] as String?,
        content: json['content'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class Choice {
  int? index;
  Message? message;
  String? finishReason;

  Choice({this.index, this.message, this.finishReason});

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        index: json['index'] as int?,
        message: json['message'] == null
            ? null
            : Message.fromJson(json['message'] as Map<String, dynamic>),
        finishReason: json['finish_reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'message': message?.toJson(),
        'finish_reason': finishReason,
      };
}

class Usage {
  int? promptTokens;
  int? completionTokens;
  int? totalTokens;

  Usage({this.promptTokens, this.completionTokens, this.totalTokens});

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        promptTokens: json['prompt_tokens'] as int?,
        completionTokens: json['completion_tokens'] as int?,
        totalTokens: json['total_tokens'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'prompt_tokens': promptTokens,
        'completion_tokens': completionTokens,
        'total_tokens': totalTokens,
      };
}
