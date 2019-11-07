import hashlib
import json
from unittest import TestCase

from blockchain import Blockchain


class BlockchainTestCase(TestCase):

    def setUp(self):
        self.blockchain = Blockchain()

    def create_block(self, proof=123, previous_hash='abc'):
        self.blockchain.new_block(proof, previous_hash)

    def create_transaction(self, sender='a', recipient='b', amount=1):
        self.blockchain.new_transaction(
            sender=sender,
            recipient=recipient,
            amount=amount
        )


class TestRegisterNodes(BlockchainTestCase):

    def test_valid_nodes(self):
        blockchain = Blockchain()

        blockchain.register_node('http://192.168.0.1:5000')

        self.assertIn('192.168.0.1:5000', blockchain.nodes)

    def test_malformed_nodes(self):
        blockchain = Blockchain()

        blockchain.register_node('http//192.168.0.1:5000')

        self.assertNotIn('192.168.0.1:5000', blockchain.nodes)

    def test_idempotency(self):
        blockchain = Blockchain()

        blockchain.register_node('http://192.168.0.1:5000')
        blockchain.register_node('http://192.168.0.1:5000')

        assert len(blockchain.nodes) == 1
