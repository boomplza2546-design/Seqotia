import io
import os
from pathlib import Path
import sys
import unittest

from PIL import Image

os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
os.environ['JWT_SECRET'] = 'test-only-secret'
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'app'))

from api.documents import _export_image, _export_pdf  # noqa: E402
from models.document import Document  # noqa: E402


class DocumentExportTest(unittest.TestCase):
    def setUp(self) -> None:
        self.document = Document(
            id=1,
            owner_id=1,
            filename='sample.txt',
            content_type='text/plain',
            extracted_text='Seqotia export test',
            source_data=b'Seqotia export test',
        )

    def test_pdf_export_is_a_pdf(self) -> None:
        self.assertTrue(_export_pdf(self.document).read().startswith(b'%PDF'))

    def test_png_export_is_a_png(self) -> None:
        output = _export_image(self.document, 'png')
        self.assertEqual(output.read(8), b'\x89PNG\r\n\x1a\n')

    def test_jpg_export_is_a_jpeg(self) -> None:
        output = _export_image(self.document, 'jpg')
        self.assertEqual(output.read(2), b'\xff\xd8')

    def test_image_import_source_can_be_read(self) -> None:
        image = Image.new('RGB', (4, 3), 'white')
        buffer = io.BytesIO()
        image.save(buffer, format='PNG')
        self.assertEqual(Image.open(io.BytesIO(buffer.getvalue())).size, (4, 3))


if __name__ == '__main__':
    unittest.main()