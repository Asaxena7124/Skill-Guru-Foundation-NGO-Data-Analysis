import pandas as pd
import numpy as np

# Load the quizzes dataset (Converts the Excel sheet into a Pandas table)
quiz_df = pd.read_excel("Quizzes_Dataset.xlsx")

# Display the type of the loaded dataset
# print(type(quiz_df))

# Display the first few rows, shape, columns, and info of the dataset
# print(quiz_df.head())
# print(quiz_df.shape)
# print(quiz_df.columns)
# print(quiz_df.info())

# Clean the column names by stripping whitespace, converting to lowercase, and replacing spaces with underscores
quiz_df.columns = quiz_df.columns.str.strip().str.lower().str.replace(" ", "_")

# print(quiz_df.columns)

# Define a mapping for renaming columns to more descriptive names
column_rename_map = {
    'quiztype': 'quiz_type',
    'quizid': 'quiz_id',
    'status': 'status',
    'mode': 'mode',
    'language': 'language',
    'questions': 'questions',
    'secperquestion': 'sec_per_question',
    'creatorname': 'creator_name',
    'creatorid': 'creator_id',
    'school': 'school',
    'participants': 'participants',
    'resultsusers': 'results_users',
    'winnername': 'winner_name',
    'winnerscore': 'winner_score',
    'winnertime': 'winner_time',
    'winnerfinalscore': 'winner_final_score',
    'createdat': 'created_at',
    'startedat': 'started_at',
    'completedat': 'completed_at',
    'description': 'description',
    'livequizlabel': 'live_quiz_label',
    'livequizsubject': 'live_quiz_subject',
    'livequiztopic': 'live_quiz_topic',
    'livequizdifficulty': 'live_quiz_difficulty',
    'livequizslot': 'live_quiz_slot'
}
# Rename the columns using the defined mapping
quiz_df.rename(columns=column_rename_map, inplace=True)
# print(quiz_df.columns) 

# Check for missing values in each column, sorted in descending order
# print(quiz_df.isnull().sum().sort_values(ascending=False))

live_cols = [
    'live_quiz_subject',
    'live_quiz_topic',
    'live_quiz_difficulty',
    'live_quiz_label',
    'live_quiz_slot'
]

quiz_df[live_cols] = quiz_df[live_cols].fillna('Unknown')
# print(quiz_df.isnull().sum().sort_values(ascending=False))

date_cols = ['created_at', 'started_at', 'completed_at']

for col in date_cols:
    quiz_df[col] = pd.to_datetime(quiz_df[col], errors='coerce')
# print(quiz_df[date_cols].dtypes)


# Create a new column 'completion_rate' as the ratio of 'results_users' to 'participants'
quiz_df['completion_rate'] = np.where(
    quiz_df['participants'] > 0,
    quiz_df['results_users'] / quiz_df['participants'],
    0
)
# print(quiz_df[['participants', 'results_users', 'completion_rate']].head())

quiz_df['quiz_duration_min'] = (
    quiz_df['completed_at'] - quiz_df['started_at']
).dt.total_seconds() / 60
# print(quiz_df[['started_at', 'completed_at', 'quiz_duration_min']].head())

quiz_df.loc[quiz_df['completion_rate'] > 1, 'completion_rate'] = 1
quiz_df.loc[quiz_df['quiz_duration_min'] < 0, 'quiz_duration_min'] = np.nan
# print(quiz_df[['completion_rate', 'quiz_duration_min']].describe())
# print(quiz_df[['completion_rate', 'quiz_duration_min']].head())


# Display value counts for categorical columns
# print(quiz_df['status'].value_counts())
# print(quiz_df['quiz_type'].value_counts())
# print(quiz_df['mode'].value_counts())

# Create a new column 'quiz_category' based on the 'live_quiz_subject' column
quiz_df['quiz_category'] = np.where(
    quiz_df['live_quiz_subject'] != 'Unknown',
    'Live Quiz',
    'Non-Live Quiz'
)

# Create a binary column 'is_completed' based on the 'status' column
quiz_df['is_completed'] = np.where(
    quiz_df['status'].str.lower() == 'completed',
    1,
    0
)

# Create engagement buckets based on completion rate
quiz_df['engagement_bucket'] = pd.cut(
    quiz_df['completion_rate'],
    bins=[-0.01, 0.25, 0.5, 0.75, 1],
    labels=['Very Low', 'Low', 'Medium', 'High']
)

# Extract date components from 'created_at' column (year, month, month name, day name, hour)
quiz_df['quiz_year'] = quiz_df['created_at'].dt.year
quiz_df['quiz_month'] = quiz_df['created_at'].dt.month
quiz_df['quiz_month_name'] = quiz_df['created_at'].dt.month_name()
quiz_df['quiz_day'] = quiz_df['created_at'].dt.day_name()
quiz_df['quiz_hour'] = quiz_df['created_at'].dt.hour
# print(quiz_df[['quiz_year', 'quiz_month', 'quiz_month_name', 'quiz_day', 'quiz_hour']].head())


quiz_df['live_quiz_difficulty'] = (
    quiz_df['live_quiz_difficulty']
    .str.lower()
    .replace({
        'easy': 'Easy',
        'medium': 'Medium',
        'hard': 'Hard',
        'intermediate': 'Intermediate',
        'unknown': 'Unknown'
    })
)
# print(quiz_df['live_quiz_difficulty'].value_counts())



# print(quiz_df[['participants', 'results_users', 'completion_rate']].describe())
# print(quiz_df['quiz_category'].value_counts())
# print(quiz_df['engagement_bucket'].value_counts())

# print(quiz_df.dtypes)
# INT columns
quiz_df['participants'] = (
    pd.to_numeric(quiz_df['participants'], errors='coerce')
    .fillna(0)
    .astype(int)
)

quiz_df['results_users'] = (
    pd.to_numeric(quiz_df['results_users'], errors='coerce')
    .fillna(0)
    .astype(int)
)

# FLOAT columns
quiz_df['completion_rate'] = (
    pd.to_numeric(quiz_df['completion_rate'], errors='coerce')
    .fillna(0.0)
)

quiz_df['quiz_duration_min'] = (
    pd.to_numeric(quiz_df['quiz_duration_min'], errors='coerce')
    .fillna(0.0)
)

quiz_df['created_at'] = pd.to_datetime(
    quiz_df['created_at'],
    errors='coerce'
)

# print(quiz_df[
#     [
#         'participants',
#         'results_users',
#         'completion_rate',
#         'quiz_duration_min'
#     ]
# ].dtypes)

# print(quiz_df[['created_at']].dtypes)
print(quiz_df.columns.tolist())
# quiz_df.to_csv("final_clean_quiz_data.csv", index=False)
