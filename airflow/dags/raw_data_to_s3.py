import datetime
import gzip
import requests
from io import BytesIO
from airflow.decorators import dag, task
from airflow.providers.amazon.aws.operators.s3 import S3CreateObjectOperator

source_url = "http://data.insideairbnb.com/australia/vic/melbourne/2023-12-13/data/listings.csv.gz"
s3_bucket = "victor-airbnb-elt"
s3_key = "raw/airbnb.csv"


@dag(
    schedule=None,
    start_date=datetime.datetime(2024, 2, 6),
    catchup=False,
    tags=["ingest"],
)
def raw_data_to_s3():
    @task
    def download_data(source_url: str):
        # download the gz file from the source url
        response = requests.get(source_url)
        print("data downloaded")
        if response.status_code == 200:
            compressed_data = BytesIO(response.content)
            with gzip.open(compressed_data, "rt", encoding="utf-8") as f:
                csv_data = f.read()
            print("data decompressed")
            return csv_data
        else:
            raise ValueError(f"Failed to download file from {source_url}")

    @task
    def upload_to_s3(csv_data):
        create_object = S3CreateObjectOperator(
            task_id="create_object",
            s3_bucket=s3_bucket,
            s3_key=s3_key,
            data=csv_data,
            aws_conn_id="airbnb-analytics",
        )
        print("object created")

        return create_object

    csv_data = download_data(source_url)
    upload_to_s3(csv_data)


raw_data_to_s3()
