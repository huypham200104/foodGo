from rasa.nlu.tokenizers.tokenizer import Tokenizer, Token
from rasa.shared.nlu.training_data.message import Message
from rasa.engine.recipes.default_recipe import DefaultV1Recipe
from rasa.engine.graph import GraphComponent, ExecutionContext
from rasa.engine.storage.resource import Resource
from rasa.engine.storage.storage import ModelStorage
from underthesea import word_tokenize

@DefaultV1Recipe.register(
    [DefaultV1Recipe.ComponentType.MESSAGE_TOKENIZER], is_trainable=False
)
class VietnameseTokenizer(Tokenizer, GraphComponent):
    """Tokenizer cho tiếng Việt dùng underthesea"""

    @classmethod
    def create(
        cls,
        config: dict,
        model_storage: ModelStorage,
        resource: Resource,
        execution_context: ExecutionContext,
    ) -> GraphComponent:
        return cls(config)

    def tokenize(self, message: Message, attribute: str):
        text = message.get(attribute)
        words = word_tokenize(text)
        tokens = self._convert_words_to_tokens(words, text)
        return self._apply_token_pattern(tokens)
