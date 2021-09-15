from datetime import datetime
import numpy as np
import pandas as pd
from tqdm import tqdm
from typing import List

reservoir_data = pd.read_csv("../data/ca_reservoirs_index.csv")


def scrape_reservoir_volume(
    codes: List = ["ALM", "BCL", "ORO"],
    start_year: int = 2020,
    start_month: int = 9,
    end_year: int = 2021,
    end_month: int = 9,
) -> pd.DataFrame:
    """Queries CDEC for given reservoir codes and returns date of reading and storage in km3.

    Args:
        codes (List, optional): [description]. Defaults to ['ALM', 'BCL', 'ORO'].
        start_year (int, optional): [description]. Defaults to 2020.
        start_month (int, optional): [description]. Defaults to 9.
        end_year (int, optional): [description]. Defaults to 2021.
        end_month (int, optional): [description]. Defaults to 9.

    Returns:
        pd.DataFrame: Results with date, km3, and code
    """

    end_date = f"{end_year}-{end_month}"
    start_date = f"{start_year}-{start_month}"
    span = (
        datetime.strptime(end_date, "%Y-%m").month
        - datetime.strptime(start_date, "%Y-%m").month
    )
    span = span + 12 * (end_year - start_year)

    res_frame = pd.DataFrame()

    for code in tqdm(codes):
        url = f"https://cdec.water.ca.gov/dynamicapp/QueryMonthly?s={code}&end={end_date}&span={span}months"

        df_out = pd.read_html(url)
        af2km3 = 1 / 810714

        if (
            code == "ORO"
            or code == "TAB"
            or code == "CFW"
            or code == "SPM"
            or code == "MIL"
        ):
            df_out = df_out[1]
            arr = np.array(df_out)
        else:
            arr = np.squeeze(np.array(df_out), axis=0)

        df = pd.DataFrame(arr[:, :3], columns=["date", "af", "drop"])
        df["af"] = pd.to_numeric(df["af"], errors="coerce")
        df.loc[df["af"] < 0, "af"] = np.nan
        df["km3"] = df["af"] * af2km3
        df = df[["date", "km3"]]
        df["code"] = code
        res_frame = res_frame.append(df)

    return res_frame


codes = np.unique(reservoir_data["CODE"])
all_data = scrape_reservoir_volume(codes=codes)
all_data.to_csv("ca_res_volume.csv", index=False)
