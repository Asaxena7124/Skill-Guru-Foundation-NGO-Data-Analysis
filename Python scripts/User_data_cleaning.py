import pandas as pd
import numpy as np
import io

# Load the users dataset (Converts the Excel sheet into a Pandas table)
user_df = pd.read_excel("Users_Dataset.xlsx")

# print(user_df.head())
# print(user_df.shape)
# print(user_df.columns)
# print(user_df.info())

# Clean the column names by stripping whitespace and converting to lowercase
user_df.columns = user_df.columns.str.strip().str.lower()
# print(user_df.columns)

user_column_rename_map = {
    # IDs
    'userid': 'user_id',
    'id': 'internal_id',

    # Personal info
    'fullname': 'full_name',
    'name': 'name',
    'username': 'user_name',
    'useremail': 'email',
    'userphone': 'phone_number',
    'phonenumber': 'phone_number',
    'countrycode': 'country_code',
    'gender': 'gender',

    # Role & status
    'roles': 'roles',
    'isonline': 'is_online',
    'is online': 'is_online',
    'status': 'status',

    # Education
    'class': 'class',
    'classlevel': 'class_level',
    'section': 'section',
    'school': 'school',
    'schoolid': 'school_id',

    # Skills & ratings (learner perspective)
    'learner skills': 'learner_skills',
    'learnerskills': 'learner_skills',
    'rating_as_learner': 'rating_as_learner',
    'learner_ratings': 'learner_ratings',

    # Guru / teacher side (keep for future)
    'guru skills': 'guru_skills',
    'guru_ratings': 'guru_ratings',
    'rating_as_guru': 'rating_as_guru',

    # Time & engagement
    'createdat': 'created_at',
    'updatedat': 'updated_at',
    'time_spent_in_call_learner': 'time_spent_as_learner',
    'call_duration_as_learner': 'call_duration_as_learner',

    # Location
    'state': 'state',
    'city': 'city',

    # System / misc (optional but clean)
    'authprovider': 'auth_provider',
    'companyid': 'company_id',
    'companyname': 'company_name'
}
user_df.rename(columns=user_column_rename_map, inplace=True)
# print(user_df.columns)


# duplicated columns check
user_df.columns[user_df.columns.duplicated()]
# print(user_df.columns[user_df.columns.duplicated()])

# Remove duplicated columns if any
user_df = user_df.loc[:, ~user_df.columns.duplicated()]
print(user_df.columns[user_df.columns.duplicated()])
# print(user_df.isnull().sum().sort_values(ascending=False))

user_df['class'] = (
    user_df['class']
    .astype(str)
    .str.extract('(\d+)')
)
# Fill missing values in 'class' column with 'Unknown'
user_df['class'] = user_df['class'].fillna('Unknown')

# Fill missing values in categorical columns with 'Unknown'
user_df['school'] = user_df['school'].fillna('Unknown')
user_df['language'] = user_df['language'].fillna('Unknown')
user_df['gender'] = user_df['gender'].fillna('Unknown')

# Create a new column 'is_active' based on 'is_online' status
user_df['is_active'] = np.where(
    user_df['is_online'] == True,
    1,
    0
)

user_df['class_group'] = pd.cut(
    pd.to_numeric(user_df['class'], errors='coerce'),
    bins=[0, 5, 8, 10, 12],
    labels=[
        'Primary (1–5)',
        'Middle (6–8)',
        'Secondary (9–10)',
        'Senior (11–12)'
    ]
)

user_analytics_df = user_df[[
    'user_id',
    'full_name',
    'email',
    'phone_number',
    'class',
    'class_group',
    'school',
    'language',
    'gender',
    'state',
    'city',
    'created_at',
    'is_active',
    'rating_as_learner',
    'time_spent_as_learner'
]]
# print(user_analytics_df.head())
# Convert 'is_active' to integer type
user_analytics_df['is_active'] = (
    user_analytics_df['is_active']
    .fillna(0)
    .astype(int)
)
# Convert 'rating_as_learner' to numeric, coercing errors to NaN
user_analytics_df['time_spent_as_learner'] = (
    pd.to_numeric(user_analytics_df['time_spent_as_learner'], errors='coerce')
)
# Fill NaN values in 'time_spent_as_learner' with 0
user_analytics_df['time_spent_as_learner'] = (
    user_analytics_df['time_spent_as_learner'].fillna(0)
)
# Convert 'rating_as_learner' to numeric, coercing errors to NaN
user_analytics_df['rating_as_learner'] = (
    pd.to_numeric(user_analytics_df['rating_as_learner'], errors='coerce')
)
# check data types
print(user_analytics_df[['is_active', 'time_spent_as_learner']].dtypes
)

# 1️⃣ FORCE is_active to be ONLY 0 or 1
user_analytics_df['is_active'] = (
    user_analytics_df['is_active']
    .astype(str)                 # convert everything to string first
    .str.lower()
    .map({'1': 1, '0': 0, 'true': 1, 'false': 0})
    .fillna(0)
    .astype(int)
)

# 2️⃣ FORCE time_spent_as_learner to be numeric ONLY
user_analytics_df['time_spent_as_learner'] = (
    pd.to_numeric(
        user_analytics_df['time_spent_as_learner'],
        errors='coerce'
    )
    .fillna(0)
)

print(user_analytics_df[['is_active', 'time_spent_as_learner']].head(20))
print(user_analytics_df[['is_active', 'time_spent_as_learner']].dtypes)

user_analytics_df.to_csv("final_clean_user_data.csv", index=False)
